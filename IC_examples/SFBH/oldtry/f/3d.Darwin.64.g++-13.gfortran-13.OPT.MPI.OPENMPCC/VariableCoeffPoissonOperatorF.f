      subroutine GSRBHELMHOLTZVC3D(
     &           dpsi
     &           ,idpsilo0,idpsilo1,idpsilo2
     &           ,idpsihi0,idpsihi1,idpsihi2
     &           ,ndpsicomp
     &           ,rhs
     &           ,irhslo0,irhslo1,irhslo2
     &           ,irhshi0,irhshi1,irhshi2
     &           ,nrhscomp
     &           ,iregionlo0,iregionlo1,iregionlo2
     &           ,iregionhi0,iregionhi1,iregionhi2
     &           ,dx
     &           ,alpha
     &           ,aCoef
     &           ,iaCoeflo0,iaCoeflo1,iaCoeflo2
     &           ,iaCoefhi0,iaCoefhi1,iaCoefhi2
     &           ,naCoefcomp
     &           ,beta
     &           ,bCoef
     &           ,ibCoeflo0,ibCoeflo1,ibCoeflo2
     &           ,ibCoefhi0,ibCoefhi1,ibCoefhi2
     &           ,nbCoefcomp
     &           ,lambda
     &           ,ilambdalo0,ilambdalo1,ilambdalo2
     &           ,ilambdahi0,ilambdahi1,ilambdahi2
     &           ,nlambdacomp
     &           ,redBlack
     &           )
      implicit none
      integer*8 ch_flops
      COMMON/ch_timer/ ch_flops
      integer ndpsicomp
      integer idpsilo0,idpsilo1,idpsilo2
      integer idpsihi0,idpsihi1,idpsihi2
      REAL*8 dpsi(
     &           idpsilo0:idpsihi0,
     &           idpsilo1:idpsihi1,
     &           idpsilo2:idpsihi2,
     &           0:ndpsicomp-1)
      integer nrhscomp
      integer irhslo0,irhslo1,irhslo2
      integer irhshi0,irhshi1,irhshi2
      REAL*8 rhs(
     &           irhslo0:irhshi0,
     &           irhslo1:irhshi1,
     &           irhslo2:irhshi2,
     &           0:nrhscomp-1)
      integer iregionlo0,iregionlo1,iregionlo2
      integer iregionhi0,iregionhi1,iregionhi2
      REAL*8 dx
      REAL*8 alpha
      integer naCoefcomp
      integer iaCoeflo0,iaCoeflo1,iaCoeflo2
      integer iaCoefhi0,iaCoefhi1,iaCoefhi2
      REAL*8 aCoef(
     &           iaCoeflo0:iaCoefhi0,
     &           iaCoeflo1:iaCoefhi1,
     &           iaCoeflo2:iaCoefhi2,
     &           0:naCoefcomp-1)
      REAL*8 beta
      integer nbCoefcomp
      integer ibCoeflo0,ibCoeflo1,ibCoeflo2
      integer ibCoefhi0,ibCoefhi1,ibCoefhi2
      REAL*8 bCoef(
     &           ibCoeflo0:ibCoefhi0,
     &           ibCoeflo1:ibCoefhi1,
     &           ibCoeflo2:ibCoefhi2,
     &           0:nbCoefcomp-1)
      integer nlambdacomp
      integer ilambdalo0,ilambdalo1,ilambdalo2
      integer ilambdahi0,ilambdahi1,ilambdahi2
      REAL*8 lambda(
     &           ilambdalo0:ilambdahi0,
     &           ilambdalo1:ilambdahi1,
     &           ilambdalo2:ilambdahi2,
     &           0:nlambdacomp-1)
      integer redBlack
      REAL*8 dxinv, lofdpsi, ldpsi
      integer n,ncomp,indtot,imin,imax
      integer i,j,k
      ncomp = ndpsicomp
      if (ncomp .ne. ndpsicomp) then
         call MAYDAYERROR()
      endif
      if (ncomp .ne. nrhscomp) then
         call MAYDAYERROR()
      endif
      if (ncomp .ne. nbCoefcomp) then
         call MAYDAYERROR()
      endif
      dxinv = (1.0d0)/(dx*dx)
      do n = 0, ncomp - 1
        do k=iregionlo2, iregionhi2
          do j=iregionlo1, iregionhi1
            imin = iregionlo0
            indtot = imin + j  + k
            imin = imin + abs(mod(indtot + redBlack, 2))
            imax = iregionhi0
            do i = imin, imax, 2
              lofdpsi =
     &            alpha * aCoef(i,j,k,n) * dpsi(i,j,k,n)
        ldpsi = 
     &     (    dpsi(i+1,j  ,k  ,n)
     &     +    dpsi(i-1,j  ,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j+1,k  ,n)
     &     +    dpsi(i  ,j-1,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j  ,k+1,n)
     &     +    dpsi(i  ,j  ,k-1,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
        ldpsi = ldpsi * dxinv * bCoef(i,j,k,n)
        lofdpsi = lofdpsi - beta*ldpsi
              dpsi(i,j,k,n) = dpsi(i,j,k,n)
     &          - lambda(i,j,k,n) * (lofdpsi - rhs(i,j,k,n))
            enddo
          enddo
        enddo
      enddo
      return
      end
      subroutine VCCOMPUTEOP3D(
     &           lofdpsi
     &           ,ilofdpsilo0,ilofdpsilo1,ilofdpsilo2
     &           ,ilofdpsihi0,ilofdpsihi1,ilofdpsihi2
     &           ,nlofdpsicomp
     &           ,dpsi
     &           ,idpsilo0,idpsilo1,idpsilo2
     &           ,idpsihi0,idpsihi1,idpsihi2
     &           ,ndpsicomp
     &           ,alpha
     &           ,aCoef
     &           ,iaCoeflo0,iaCoeflo1,iaCoeflo2
     &           ,iaCoefhi0,iaCoefhi1,iaCoefhi2
     &           ,naCoefcomp
     &           ,beta
     &           ,bCoef
     &           ,ibCoeflo0,ibCoeflo1,ibCoeflo2
     &           ,ibCoefhi0,ibCoefhi1,ibCoefhi2
     &           ,nbCoefcomp
     &           ,iregionlo0,iregionlo1,iregionlo2
     &           ,iregionhi0,iregionhi1,iregionhi2
     &           ,dx
     &           )
      implicit none
      integer*8 ch_flops
      COMMON/ch_timer/ ch_flops
      integer nlofdpsicomp
      integer ilofdpsilo0,ilofdpsilo1,ilofdpsilo2
      integer ilofdpsihi0,ilofdpsihi1,ilofdpsihi2
      REAL*8 lofdpsi(
     &           ilofdpsilo0:ilofdpsihi0,
     &           ilofdpsilo1:ilofdpsihi1,
     &           ilofdpsilo2:ilofdpsihi2,
     &           0:nlofdpsicomp-1)
      integer ndpsicomp
      integer idpsilo0,idpsilo1,idpsilo2
      integer idpsihi0,idpsihi1,idpsihi2
      REAL*8 dpsi(
     &           idpsilo0:idpsihi0,
     &           idpsilo1:idpsihi1,
     &           idpsilo2:idpsihi2,
     &           0:ndpsicomp-1)
      REAL*8 alpha
      integer naCoefcomp
      integer iaCoeflo0,iaCoeflo1,iaCoeflo2
      integer iaCoefhi0,iaCoefhi1,iaCoefhi2
      REAL*8 aCoef(
     &           iaCoeflo0:iaCoefhi0,
     &           iaCoeflo1:iaCoefhi1,
     &           iaCoeflo2:iaCoefhi2,
     &           0:naCoefcomp-1)
      REAL*8 beta
      integer nbCoefcomp
      integer ibCoeflo0,ibCoeflo1,ibCoeflo2
      integer ibCoefhi0,ibCoefhi1,ibCoefhi2
      REAL*8 bCoef(
     &           ibCoeflo0:ibCoefhi0,
     &           ibCoeflo1:ibCoefhi1,
     &           ibCoeflo2:ibCoefhi2,
     &           0:nbCoefcomp-1)
      integer iregionlo0,iregionlo1,iregionlo2
      integer iregionhi0,iregionhi1,iregionhi2
      REAL*8 dx
      REAL*8 dxinv, ldpsi
      integer n,ncomp
      integer i,j,k
      ncomp = ndpsicomp
      if (ncomp .ne. nlofdpsicomp) then
         call MAYDAYERROR()
      endif
      if (ncomp .ne. nbCoefcomp) then
         call MAYDAYERROR()
      endif
      dxinv = (1.0d0)/(dx*dx)
      do n = 0, ncomp-1
      do k = iregionlo2,iregionhi2
      do j = iregionlo1,iregionhi1
      do i = iregionlo0,iregionhi0
          lofdpsi(i,j,k,n) =
     &        alpha * aCoef(i,j,k,n) * dpsi(i,j,k,n)
        ldpsi = 
     &     (    dpsi(i+1,j  ,k  ,n)
     &     +    dpsi(i-1,j  ,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j+1,k  ,n)
     &     +    dpsi(i  ,j-1,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j  ,k+1,n)
     &     +    dpsi(i  ,j  ,k-1,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
        ldpsi = ldpsi * dxinv * beta * bCoef(i,j,k,n)
        lofdpsi(i,j,k,n) =  lofdpsi(i,j,k,n) - ldpsi
      enddo
      enddo
      enddo
      enddo
      return
      end
      subroutine VCCOMPUTERES3D(
     &           res
     &           ,ireslo0,ireslo1,ireslo2
     &           ,ireshi0,ireshi1,ireshi2
     &           ,nrescomp
     &           ,dpsi
     &           ,idpsilo0,idpsilo1,idpsilo2
     &           ,idpsihi0,idpsihi1,idpsihi2
     &           ,ndpsicomp
     &           ,rhs
     &           ,irhslo0,irhslo1,irhslo2
     &           ,irhshi0,irhshi1,irhshi2
     &           ,nrhscomp
     &           ,alpha
     &           ,aCoef
     &           ,iaCoeflo0,iaCoeflo1,iaCoeflo2
     &           ,iaCoefhi0,iaCoefhi1,iaCoefhi2
     &           ,naCoefcomp
     &           ,beta
     &           ,bCoef
     &           ,ibCoeflo0,ibCoeflo1,ibCoeflo2
     &           ,ibCoefhi0,ibCoefhi1,ibCoefhi2
     &           ,nbCoefcomp
     &           ,iregionlo0,iregionlo1,iregionlo2
     &           ,iregionhi0,iregionhi1,iregionhi2
     &           ,dx
     &           )
      implicit none
      integer*8 ch_flops
      COMMON/ch_timer/ ch_flops
      integer nrescomp
      integer ireslo0,ireslo1,ireslo2
      integer ireshi0,ireshi1,ireshi2
      REAL*8 res(
     &           ireslo0:ireshi0,
     &           ireslo1:ireshi1,
     &           ireslo2:ireshi2,
     &           0:nrescomp-1)
      integer ndpsicomp
      integer idpsilo0,idpsilo1,idpsilo2
      integer idpsihi0,idpsihi1,idpsihi2
      REAL*8 dpsi(
     &           idpsilo0:idpsihi0,
     &           idpsilo1:idpsihi1,
     &           idpsilo2:idpsihi2,
     &           0:ndpsicomp-1)
      integer nrhscomp
      integer irhslo0,irhslo1,irhslo2
      integer irhshi0,irhshi1,irhshi2
      REAL*8 rhs(
     &           irhslo0:irhshi0,
     &           irhslo1:irhshi1,
     &           irhslo2:irhshi2,
     &           0:nrhscomp-1)
      REAL*8 alpha
      integer naCoefcomp
      integer iaCoeflo0,iaCoeflo1,iaCoeflo2
      integer iaCoefhi0,iaCoefhi1,iaCoefhi2
      REAL*8 aCoef(
     &           iaCoeflo0:iaCoefhi0,
     &           iaCoeflo1:iaCoefhi1,
     &           iaCoeflo2:iaCoefhi2,
     &           0:naCoefcomp-1)
      REAL*8 beta
      integer nbCoefcomp
      integer ibCoeflo0,ibCoeflo1,ibCoeflo2
      integer ibCoefhi0,ibCoefhi1,ibCoefhi2
      REAL*8 bCoef(
     &           ibCoeflo0:ibCoefhi0,
     &           ibCoeflo1:ibCoefhi1,
     &           ibCoeflo2:ibCoefhi2,
     &           0:nbCoefcomp-1)
      integer iregionlo0,iregionlo1,iregionlo2
      integer iregionhi0,iregionhi1,iregionhi2
      REAL*8 dx
      REAL*8 dxinv, ldpsi
      integer n,ncomp
      integer i,j,k
      ncomp = ndpsicomp
      if (ncomp .ne. nrescomp) then
         call MAYDAYERROR()
      endif
      if (ncomp .ne. nbCoefcomp) then
         call MAYDAYERROR()
      endif 
      dxinv = (1.0d0)/(dx*dx)
      do n = 0, ncomp-1
      do k = iregionlo2,iregionhi2
      do j = iregionlo1,iregionhi1
      do i = iregionlo0,iregionhi0
          res(i,j,k,n) =
     &        rhs(i,j,k,n)
     &      - alpha * aCoef(i,j,k,n) * dpsi(i,j,k,n)
        ldpsi = 
     &     (    dpsi(i+1,j  ,k  ,n)
     &     +    dpsi(i-1,j  ,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j+1,k  ,n)
     &     +    dpsi(i  ,j-1,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j  ,k+1,n)
     &     +    dpsi(i  ,j  ,k-1,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
        ldpsi = ldpsi * dxinv * beta * bCoef(i,j,k,n)
        res(i,j,k,n) = res(i,j,k,n) + ldpsi
      enddo
      enddo
      enddo
      enddo
      return
      end
      subroutine RESTRICTRESVC3D(
     &           res
     &           ,ireslo0,ireslo1,ireslo2
     &           ,ireshi0,ireshi1,ireshi2
     &           ,nrescomp
     &           ,dpsi
     &           ,idpsilo0,idpsilo1,idpsilo2
     &           ,idpsihi0,idpsihi1,idpsihi2
     &           ,ndpsicomp
     &           ,rhs
     &           ,irhslo0,irhslo1,irhslo2
     &           ,irhshi0,irhshi1,irhshi2
     &           ,nrhscomp
     &           ,alpha
     &           ,aCoef
     &           ,iaCoeflo0,iaCoeflo1,iaCoeflo2
     &           ,iaCoefhi0,iaCoefhi1,iaCoefhi2
     &           ,naCoefcomp
     &           ,beta
     &           ,bCoef
     &           ,ibCoeflo0,ibCoeflo1,ibCoeflo2
     &           ,ibCoefhi0,ibCoefhi1,ibCoefhi2
     &           ,nbCoefcomp
     &           ,iregionlo0,iregionlo1,iregionlo2
     &           ,iregionhi0,iregionhi1,iregionhi2
     &           ,dx
     &           )
      implicit none
      integer*8 ch_flops
      COMMON/ch_timer/ ch_flops
      integer nrescomp
      integer ireslo0,ireslo1,ireslo2
      integer ireshi0,ireshi1,ireshi2
      REAL*8 res(
     &           ireslo0:ireshi0,
     &           ireslo1:ireshi1,
     &           ireslo2:ireshi2,
     &           0:nrescomp-1)
      integer ndpsicomp
      integer idpsilo0,idpsilo1,idpsilo2
      integer idpsihi0,idpsihi1,idpsihi2
      REAL*8 dpsi(
     &           idpsilo0:idpsihi0,
     &           idpsilo1:idpsihi1,
     &           idpsilo2:idpsihi2,
     &           0:ndpsicomp-1)
      integer nrhscomp
      integer irhslo0,irhslo1,irhslo2
      integer irhshi0,irhshi1,irhshi2
      REAL*8 rhs(
     &           irhslo0:irhshi0,
     &           irhslo1:irhshi1,
     &           irhslo2:irhshi2,
     &           0:nrhscomp-1)
      REAL*8 alpha
      integer naCoefcomp
      integer iaCoeflo0,iaCoeflo1,iaCoeflo2
      integer iaCoefhi0,iaCoefhi1,iaCoefhi2
      REAL*8 aCoef(
     &           iaCoeflo0:iaCoefhi0,
     &           iaCoeflo1:iaCoefhi1,
     &           iaCoeflo2:iaCoefhi2,
     &           0:naCoefcomp-1)
      REAL*8 beta
      integer nbCoefcomp
      integer ibCoeflo0,ibCoeflo1,ibCoeflo2
      integer ibCoefhi0,ibCoefhi1,ibCoefhi2
      REAL*8 bCoef(
     &           ibCoeflo0:ibCoefhi0,
     &           ibCoeflo1:ibCoefhi1,
     &           ibCoeflo2:ibCoefhi2,
     &           0:nbCoefcomp-1)
      integer iregionlo0,iregionlo1,iregionlo2
      integer iregionhi0,iregionhi1,iregionhi2
      REAL*8 dx
      REAL*8 denom, dxinv, lofdpsi, ldpsi
      integer n, ncomp
      integer i,j,k
      integer ii,jj,kk
      ncomp = ndpsicomp
      dxinv = (1.0d0) / (dx*dx)
      denom = 2  *2  *2
      do n = 0, ncomp-1
      do k = iregionlo2,iregionhi2
      do j = iregionlo1,iregionhi1
      do i = iregionlo0,iregionhi0
          ii = i/2 
          jj = j/2 
          kk = k/2 
          lofdpsi =
     &        alpha * aCoef(i,j,k,n) * dpsi(i,j,k,n)
        ldpsi = 
     &     (    dpsi(i+1,j  ,k  ,n)
     &     +    dpsi(i-1,j  ,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j+1,k  ,n)
     &     +    dpsi(i  ,j-1,k  ,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
     $     +(   dpsi(i  ,j  ,k+1,n)
     &     +    dpsi(i  ,j  ,k-1,n)
     $     -(2.0d0)*dpsi(i  ,j  ,k  ,n)) 
          ldpsi = ldpsi * dxinv * beta * bCoef(i,j,k,n)
          lofdpsi = lofdpsi - ldpsi
          res(ii,jj,kk,n) = res(ii,jj,kk,n)
     &                            + (rhs(i,j,k,n) - lofdpsi) / denom
      enddo
      enddo
      enddo
      enddo
      return
      end
      subroutine SUMFACES(
     &           lhs
     &           ,ilhslo0,ilhslo1,ilhslo2
     &           ,ilhshi0,ilhshi1,ilhshi2
     &           ,nlhscomp
     &           ,beta
     &           ,bCoefs
     &           ,ibCoefslo0,ibCoefslo1,ibCoefslo2
     &           ,ibCoefshi0,ibCoefshi1,ibCoefshi2
     &           ,nbCoefscomp
     &           ,iboxlo0,iboxlo1,iboxlo2
     &           ,iboxhi0,iboxhi1,iboxhi2
     &           ,dir
     &           ,scale
     &           )
      implicit none
      integer*8 ch_flops
      COMMON/ch_timer/ ch_flops
      integer CHF_ID(0:5,0:5)
      data CHF_ID/ 1,0,0,0,0,0 ,0,1,0,0,0,0 ,0,0,1,0,0,0 ,0,0,0,1,0,0 ,0
     &,0,0,0,1,0 ,0,0,0,0,0,1 /
      integer nlhscomp
      integer ilhslo0,ilhslo1,ilhslo2
      integer ilhshi0,ilhshi1,ilhshi2
      REAL*8 lhs(
     &           ilhslo0:ilhshi0,
     &           ilhslo1:ilhshi1,
     &           ilhslo2:ilhshi2,
     &           0:nlhscomp-1)
      REAL*8 beta
      integer nbCoefscomp
      integer ibCoefslo0,ibCoefslo1,ibCoefslo2
      integer ibCoefshi0,ibCoefshi1,ibCoefshi2
      REAL*8 bCoefs(
     &           ibCoefslo0:ibCoefshi0,
     &           ibCoefslo1:ibCoefshi1,
     &           ibCoefslo2:ibCoefshi2,
     &           0:nbCoefscomp-1)
      integer iboxlo0,iboxlo1,iboxlo2
      integer iboxhi0,iboxhi1,iboxhi2
      integer dir
      REAL*8 scale
      REAL*8 sumVal
      integer i,j,k
      integer ii,jj,kk
      integer n
      ii = CHF_ID(0,dir)
      jj = CHF_ID(1,dir)
      kk = CHF_ID(2,dir)
      do n = 0, nlhscomp-1
      do k = iboxlo2,iboxhi2
      do j = iboxlo1,iboxhi1
      do i = iboxlo0,iboxhi0
          sumVal = bCoefs(i+ii,j+jj,k+kk,n)
     &           + bCoefs(i   ,j   ,k   ,n)
          lhs(i,j,k,n) = lhs(i,j,k,n) + scale * beta * sumVal
      enddo
      enddo
      enddo
      enddo
      return
      end
