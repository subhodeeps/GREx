#rhsevolution.py

# python modules
import numpy as np
import time

# homemade code
from source.uservariables import *
from source.gridfunctions import *
from source.fourthorderderivatives import *
from source.logderivatives import *
from source.tensoralgebra import *
from source.misnersharp import *

# from source.initialdata import rho_bkg_ini, t_ini
from source.initialdata import *  


    
################################ Main RHS get function  
# skip_idxs = []

def get_rhs(t_i, current_state, params, sigma, progress_bar, time_state) :     
 
    R_max = params.r_max
    N_r = params.N_r
    r_is_logarithmic = params.r_is_logarithmic
    t_ini = params.t_ini
    rho_bkg_ini = params.rho_bkg_ini

    # Uncomment for timing and tracking progress
    # start_time = time.time()
    
    # Set up grid values
    dx, N, r, logarithmic_dr = setup_grid(R_max, N_r, r_is_logarithmic)
    
    # predefine some userful quantities
    oneoverlogdr = 1.0 / logarithmic_dr
    oneoverlogdr2 = oneoverlogdr * oneoverlogdr
    oneoverdx  = 1.0 / dx
    oneoverdxsquared = oneoverdx * oneoverdx
    
    # this is where the rhs will go
    rhs = np.zeros_like(current_state)                                  
    
    ####################################################################################################
    #unpackage the state vector for readability - these are the vectors of values across r values at time t_i
    # see uservariables.py for naming conventions
    
    fill_outer_boundary(current_state, dx, N, r_is_logarithmic)
    
    # Unpack variables from current_state - see uservariables.py
    ### u, v , phi, hrr, htt, hpp, K, arr, att, app, lambdar, shiftr, br, lapse = unpack_state(current_state, N_r) 
    U, R, M, rho = unpack_state(current_state, N_r) 
    
    
    # B.C. 
    U[-num_ghosts:] = U[-num_ghosts-1]
    M[-num_ghosts:] = M[-num_ghosts-1]
    R[-num_ghosts:] = R[-num_ghosts-1]
    
           
    # t0 = time.time()
    # print("grid and var setup done in ", t0-start_time)
    
       
    ###################################################################

    # get the various derivs that we need to evolve things
    if(r_is_logarithmic) : #take logarithmic derivatives
        dUdr       = get_logdfdx(U, oneoverdx)
        dRdr       = get_logdfdx(R, oneoverdx)
        dMdr       = get_logdfdx(M, oneoverdx)
        drhodr     = get_logdfdx(rho, oneoverdx)
        print("Using log r in spatial cordinates is experimental. Currently don't work.")
        raise()
        
    else :
        
        # # second derivatives
        # d2Udr2     = get_d2fdx2(U, oneoverdxsquared)
        # d2Mdr2   = get_d2fdx2(M, oneoverdxsquared)
        # d2Rdr2     = get_d2fdx2(R, oneoverdxsquared)
        # d2rhodxr2   = get_d2fdx2(rho, oneoverdxsquared)

        # first derivatives
        dUdr       = get_dfdx(U, oneoverdx)
        dRdr       = get_dfdx(R, oneoverdx)
        dMdr       = get_dfdx(M, oneoverdx)
        drhodr     = get_dfdx(rho, oneoverdx)
    
    
    ##### EXPERIMENTAL WARNING!!!  CJ TODO
    # if t_i > 2000:
        # ulim = 0.1
        # dUdr[dUdr>ulim] = ulim
        # dUdr[dUdr<-ulim] = -ulim

    # impose constraint in outer ghosts
    for ix in range(N-num_ghosts, N) :        
        rho[ix] = 4*np.pi*R[ix]*R[ix] * dRdr[ix] / (dMdr[ix] +0.0001) 
  
    pack_state(current_state, N_r, U, R , M, rho) 

    # t2 = time.time()
    # print("derivs found in ", t2 - t1)
        
    ####################################################################################################
    
    # make containers for rhs values
    rhs_U   = np.zeros_like(U)
    rhs_R   = np.zeros_like(R)
    rhs_M = np.zeros_like(M)
    rhs_rho = np.zeros_like(rho)
    
    
    ###################################################################   
    # now iterate over the grid (vector) and calculate the rhs values
    # note that we do the ghost cells separately below
    for ix in range(num_ghosts, N-num_ghosts) :
        
        #t0A = time.time()
        
        # where am I?
        r_here = r[ix]
                      
        # print("Assign vars done in ", t1A - t0A) 
        # End of: Calculate some useful quantities, now start RHS
        #########################################################

        
        # Get the auxiliary vars        
        omega = get_omega(params)        
        
        rho_bkg = get_rho_bkg(t_i/t_ini, rho_bkg_ini)
        
        # if rho[ix] <0 :  rho[ix] = rho_bkg
        A = get_A(rho[ix], rho_bkg, omega)
        Gamma = get_Gamma(U[ix], R[ix], M[ix])
        
        # Get the Misner-sharp rhs 
        rhs_U[ix]     =  get_rhs_U(U[ix], M[ix], R[ix], rho[ix], dRdr[ix], drhodr[ix], A, Gamma, omega)
        
        rhs_R[ix]     =  get_rhs_R(U[ix], A)
        
        rhs_M[ix]     =  get_rhs_M(U[ix], R[ix], rho[ix], A, omega) 
        
        rhs_rho[ix]   =  get_rhs_rho(U[ix], R[ix], rho[ix], dUdr[ix], dRdr[ix], A, omega)
        
                   
    # end of rhs iteration over grid points   
    # t3 = time.time()
    # print("rhs iteration over grid done in ", t3 - t2)
    
    ####################################################################################################


	# Boundary conditions at the end
    rhs_rho[-num_ghosts:] = 0
    rhs_U[-num_ghosts:] = 0
    rhs_R[-num_ghosts:] = 0
    rhs_M[-num_ghosts:] = 0
    
    rhs_rho[-1] = 0
    rhs_U[-1] = 0
    rhs_R[-1] = 0
    rhs_M[-1]=0


    #package up the rhs values into a vector rhs (like current_state) for return - see uservariables.py
    pack_state(rhs, N_r, rhs_U, rhs_R , rhs_M, rhs_rho)

    #################################################################################################### 
            
    # finally add Kreiss Oliger dissipation which removed noise at frequency of grid resolution
    # sigma = 10.0 # kreiss-oliger damping coefficient, max_step should be limited to 0.1 R_max/N_r    ###CJ change to params.sigma
    
    diss = np.zeros_like(current_state) 
    for ivar in range(0, NUM_VARS) :
        ivar_values = current_state[(ivar)*N:(ivar+1)*N]
        ivar_diss = np.zeros_like(ivar_values)
        if(r_is_logarithmic) :
            ivar_diss = get_logdissipation(ivar_values, oneoverlogdr, sigma)
        else : 
            ivar_diss = get_dissipation(ivar_values, oneoverdx, sigma)
        diss[(ivar)*N:(ivar+1)*N] = ivar_diss
    rhs += diss
    
    # t4 = time.time()
    # print("KO diss done in ", t4 - t3)    
    
    #################################################################################################### 
    
    # see gridfunctions for these, or https://github.com/KAClough/BabyGRChombo/wiki/Useful-code-background
    
    # overwrite outer boundaries with extrapolation (order specified in uservariables.py)
    # fill_outer_boundary(current_state, dx, N, r_is_logarithmic)
    # fill_outer_boundary(rhs, dx, N, r_is_logarithmic)


	# Boundary Conditions at origin
    # overwrite inner cells using parity under r -> - r
    fill_inner_boundary(current_state, dx, N, r_is_logarithmic)
    fill_inner_boundary(rhs, dx, N, r_is_logarithmic)
    
    # t5 = time.time()
    # print("Fill boundaries done in ", t5 - t4) 
                
    #rhs[~(rhs==rhs)] = 0     # freeze singular points, often at outer ghosts.                   
                
    #################################################################################################### 
    
    # Some code for checking timing and progress output
    
    # state is a list containing last updated time t:
    # state = [last_t, dt for progress bar]
    # its values can be carried between function calls throughout the ODE integration
    last_t, deltat = time_state
    
    # call update(n) here where n = (t - last_t) / dt
    n = deltat # int((t_i - last_t)/deltat)
    progress_bar.update(round(n,3))
    # we need this to take into account that n is a rounded number:
    time_state[0] = last_t +  n
    
    # t6 = time.time()
    # print("Check timing and output ", t6 - t5) 
    
    # end_time = time.time()
    # print("total rhs time at t= ", t_i, " is, ", end_time-start_time)
        
    ####################################################################################################
    
    #Finally return the rhs
    return rhs




    

def get_rhs_chev(t_i, current_state, R_max, N_r, r_is_logarithmic, sigma, progress_bar, time_state) :     
	
	# TODO
    
    #Finally return the rhs
    return rhs
