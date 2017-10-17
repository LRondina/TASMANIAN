PROGRAM TasmanianSGExample
  USE TasmanianSG, ONLY: tsgInitialize, tsgFinalize, tsgNewGridID, tsgFreeGridID, &
       tsgGetVersionMajor, tsgGetVersionMinor, tsgGetLicense, &
       tsgMakeGlobalGrid, tsgMakeSequenceGrid, tsgMakeLocalPolynomialGrid, tsgMakeWaveletGrid, &
       tsgUpdateGlobalGrid, tsgUpdateSequenceGrid, tsgRead, tsgWrite, &
       tsgGetAlpha, tsgGetBeta, tsgGetOrder, tsgGetNumDimensions, tsgGetNumOutputs, tsgGetRule, &
       tsgGetNumLoaded, tsgGetNumNeeded, tsgGetNumPoints, &
       tsgGetLoadedPoints, tsgGetNeededPoints, tsgGetPoints, &
       tsgGetLoadedPointsStatic, tsgGetNeededPointsStatic, tsgGetPointsStatic, &
       tsgLoadNeededPoints, tsgEvaluate, tsgEvaluateFast, tsgEvaluateBatch, tsgIntegrate, &
       tsgGetQuadratureWeights, tsgGetQuadratureWeightsStatic, &
       tsgGetInterpolationWeights, tsgGetInterpolationWeightsStatic, &
       tsgSetDomainTransform, tsgIsSetDomainTransfrom, tsgClearDomainTransform, tsgGetDomainTransform
IMPLICIT NONE
  INTEGER :: gridID, dims, outs, level
  INTEGER :: gridID1, gridID2, gridID3, N1, N2, N3
  INTEGER :: N, i, j, verm, vern
  DOUBLE PRECISION :: err1, err2, err3, exact
  REAL :: cpuStart, cpuEnd, stages(2,3)
  !INTEGER :: aweights(3)
  CHARACTER, pointer :: string(:)
  DOUBLE PRECISION, pointer :: points(:,:), weights(:)
  DOUBLE PRECISION :: x, y, integ, E
  DOUBLE PRECISION, allocatable :: transformA(:), transformB(:), values(:,:), tvalues(:,:)
  DOUBLE PRECISION, allocatable :: res(:), res2(:,:), pnt(:)
  DOUBLE PRECISION :: desired_x(2)
  DOUBLE PRECISION :: randPoints(4,1000)
  

! This is the sound "Glaucodon Ballaratensis" makes :)
!  WRITE(*,*) "Ghurrrrrphurrr"

! ============ reference table of rules ============ !
!  1: clenshaw-curtis             2: clenshaw-curtis-zero   
!  3: chebyshev                   4: chebyshev-odd
!  5: gauss-legendre              6: gauss-legendreodd
!  7: gauss-patterson             8: leja  
!  9: lejaodd                    10: rleja 
! 11: rleja-odd                  12: rleja-double-2
! 13: rleja-double-4             14: rleja-shifted 
! 15: rleja-shifted-even         16: rleja-shifted-double
! 17: max-lebesgue               18: max-lebesgue-odd
! 19: min-lebesgue               20: min-lebesgue-odd
! 21: min-delta                  22: min-delta-odd
! 23: gauss-chebyshev-1          24: gauss-chebyshev-1-odd
! 25: gauss-chebyshev-2          26: gauss-chebyshev-2-odd
! 27: fejer2                     28: gauss-gegenbauer
! 29: gauss-gegenbauer-odd       30: gauss-jacobi
! 31: gauss-jacobi-odd           32: gauss-laguerre
! 33: gauss-laguerre-odd         34: gauss-hermite
! 35: gauss-hermite-odd          36: custom-tabulated
! 37: localp                     38: localp-zero
! 39: semi-localp                40: wavelet

! ============ reference table of grid types ============ !
!  1: level                       2: curved
!  3: iptotal                     4: ipcurved
!  5: qptotal                     6: qpcurved
!  7: hyperbolic                  8: iphyperbolic
!  9: qphyperbolic               10: tensor
! 11: iptensor                   12: qptensor

! ============ reference table of refinement types ============ !
!  1: classic            2: parents first
!  3: directional        4: FDS (both parents and directions)

! ==================================================================== !  
! EXAMPLE 1: integrate: f(x,y) = exp(-x^2) * cos(y) over [-1,1] x [-1,1]
! using classical Smolyak grid with Clenshaw-Curtis points and weights

! must call tsgInitialize() once per program
  CALL tsgInitialize()
  
  verm = tsgGetVersionMajor()
  vern = tsgGetVersionMinor()
  
  ! WARNING: do not DEALLOCATE the string pointer, it is const char*
  string => tsgGetLicense()
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Tasmanian Sparse Grids Fortran Module (TasmanianSG)"
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,"(A,I2,A,I1)") " Tasmanian Sparse Grid module, version: ", verm, ".", vern
  WRITE(*,"(A,40A)")       "                               license: ", string
  WRITE(*,*)
  
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Example 1:  integrate f(x,y) = exp(-x^2) * cos(y), using clenshaw-curtis level nodes"
  
  dims = 2
  level = 6
  
! before you use a grid, you must ask for a new valid grid ID
  gridID = tsgNewGridID()
  
! clenshaw-curtis = 1, type_level = 1
  CALL tsgMakeGlobalGrid(gridID, dims, 0, level, 1, 1)
  
  points => tsgGetPoints(gridID)
  weights => tsgGetQuadratureWeights(gridID)
  
  N = tsgGetNumPoints(gridID)
  integ = 0.0
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    integ = integ + weights(i) * exp(-x*x) * cos(y)
  END DO
  
  E = abs(integ - 2.513723354063905D+00)
  
  WRITE(*,"(A,I4)")   "      at level:     ", level
  WRITE(*,"(A,I4,A)") "      the grid has: ", N, " points"
  WRITE(*,"(A,E25.16)") "      integral:  ", integ
  WRITE(*,"(A,E25.16)") "      error:     ", E
  WRITE(*,*)
  
  level = 7
! no need to ask for a new ID when remaking an existing grid
  CALL tsgMakeGlobalGrid(gridID, dims, 0, level, 1, 1)
  
! do not forget to release the memory associated with points and weights
  DEALLOCATE(points)
  DEALLOCATE(weights)
  points => tsgGetPoints(gridID)
  weights => tsgGetQuadratureWeights(gridID)
  
  N = tsgGetNumPoints(gridID)
  integ = 0.0
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    integ = integ + weights(i) * exp(-x*x) * cos(y)
  END DO
  
  E = abs(integ - 2.513723354063905D+00)
  WRITE(*,"(A,I4)")   "      at level:     ", level
  WRITE(*,"(A,I4,A)") "      the grid has: ", N, " points"
  WRITE(*,"(A,E25.16)") "      integral:  ", integ
  WRITE(*,"(A,E25.16)") "      error:     ", E
  WRITE(*,*)
  
  DEALLOCATE(points)
  DEALLOCATE(weights)
  
! after calling tsgFreeGridID(), we can no longer use this gridID
! until we call tsgNewGridID()
  CALL tsgFreeGridID(gridID)

! ==================================================================== !
! EXAMPLE 2: integrate: f(x,y) = exp(-x^2) * cos(y) 
!                       over (x,y) in [-5,5] x [-2,3]
! using Gauss-Patterson rules chosen to integrate exactly polynomials of
! total degree up to degree specified by prec

  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Example 2: integrate f(x,y) = exp(-x^2) * cos(y) over [-5,5] x [-2,3] using  Gauss-Patterson nodes"

  dims = 2
  level = 20
  
  ALLOCATE(transformA(dims))
  ALLOCATE(transformB(dims))
  transformA(1) = -5.0
  transformA(2) = -2.0
  transformB(1) =  5.0
  transformB(2) =  3.0
  
! need new gridID, since we freed this earlier
  gridID = tsgNewGridID()
  
! gauss-patterson = 7, type_qptotal = 5
  CALL tsgMakeGlobalGrid(gridID, dims, 0, level, 5, 7)
  CALL tsgSetDomainTransform(gridID, transformA, transformB)
  
  points => tsgGetPoints(gridID)
  weights => tsgGetQuadratureWeights(gridID)
  
  N = tsgGetNumPoints(gridID)
  integ = 0.0
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    integ = integ + weights(i) * exp(-x*x) * cos(y)
  END DO
  
  E = abs(integ - 1.861816427518323D+00)
  WRITE(*,"(A,I4)")   "      at precision:   ", level
  WRITE(*,"(A,I4,A)") "      the grid has:   ", N, " points"
  WRITE(*,"(A,E25.16)") "      integral:    ", integ
  WRITE(*,"(A,E25.16)") "      error:       ", E
  WRITE(*,*)
  
  level = 40
! no need to ask for a new ID when remaking an existing grid
  CALL tsgMakeGlobalGrid(gridID, dims, 0, level, 5, 7)
  CALL tsgSetDomainTransform(gridID, transformA, transformB)
  
! do not forget to release the memory associated with points and weights
  DEALLOCATE(points)
  DEALLOCATE(weights)
  points => tsgGetPoints(gridID)
  weights => tsgGetQuadratureWeights(gridID)
  
  N = tsgGetNumPoints(gridID)
  integ = 0.0
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    integ = integ + weights(i) * exp(-x*x) * cos(y)
  END DO
  
  E = abs(integ - 1.861816427518323D+00)
  WRITE(*,"(A,I4)")   "      at precision:   ", level
  WRITE(*,"(A,I4,A)") "      the grid has:   ", N, " points"
  WRITE(*,"(A,E25.16)") "      integral:    ", integ
  WRITE(*,"(A,E25.16)") "      error:       ", E
  WRITE(*,*)
  
  DEALLOCATE(points)
  DEALLOCATE(weights)
  ! keep transformA and transformB for the next example
  CALL tsgFreeGridID(gridID)

! ==================================================================== !
! EXAMPLE 3: integrate: f(x,y) = exp(-x^2) * cos(y) 
!                       over (x,y) in [-5,5] x [-2,3]
! using different rules

  gridID1 = tsgNewGridID()
  gridID2 = tsgNewGridID()
  gridID3 = tsgNewGridID()
  
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Example 3: integrate f(x,y) = exp(-x^2) * cos(y) over [-5,5] x [-2,3] using different rules"
  WRITE(*,*)
  
  WRITE(*,*) "               Clenshaw-Curtis      Gauss-Legendre     Gauss-Patterson"
  WRITE(*,*) " precision    points     error    points     error    points     error"
  
  DO level = 9, 30, 4
    ! clenshaw-curtis = 1, gauss-legendre = 5, gauss-patterson = 7
    ! type_qptotal = 5
    CALL tsgMakeGlobalGrid(gridID1, dims, 0, level, 5, 1)
    CALL tsgSetDomainTransform(gridID1, transformA, transformB)
    CALL tsgMakeGlobalGrid(gridID2, dims, 0, level, 5, 5)
    CALL tsgSetDomainTransform(gridID2, transformA, transformB)
    CALL tsgMakeGlobalGrid(gridID3, dims, 0, level, 5, 7)
    CALL tsgSetDomainTransform(gridID3, transformA, transformB)
    
    points => tsgGetPoints(gridID1)
    weights => tsgGetQuadratureWeights(gridID1)
    N1 = tsgGetNumPoints(gridID1)
    integ = 0.0
    DO i = 1, N1
      x = points(1, i)
      y = points(2, i)
      integ = integ + weights(i) * exp(-x*x) * cos(y)
    END DO
    err1 = abs(integ - 1.861816427518323D+00)
    DEALLOCATE(points)
    DEALLOCATE(weights)
    
    points => tsgGetPoints(gridID2)
    weights => tsgGetQuadratureWeights(gridID2)
    N2 = tsgGetNumPoints(gridID2)
    integ = 0.0
    DO i = 1, N2
      x = points(1, i)
      y = points(2, i)
      integ = integ + weights(i) * exp(-x*x) * cos(y)
    END DO
    err2 = abs(integ - 1.861816427518323D+00)
    DEALLOCATE(points)
    DEALLOCATE(weights)
    
    points => tsgGetPoints(gridID3)
    weights => tsgGetQuadratureWeights(gridID3)
    N3 = tsgGetNumPoints(gridID3)
    integ = 0.0
    DO i = 1, N3
      x = points(1, i)
      y = points(2, i)
      integ = integ + weights(i) * exp(-x*x) * cos(y)
    END DO
    err3 = abs(integ - 1.861816427518323D+00)
    DEALLOCATE(points)
    DEALLOCATE(weights)
    
    WRITE(*,"(I10,I10,E11.3,I9,E11.3,I9,E11.3)") level, N1, err1, N2, err2, N3, err3

  END DO
  WRITE(*,*)
  
  CALL tsgFreeGridID(gridID1)
  CALL tsgFreeGridID(gridID2)
  CALL tsgFreeGridID(gridID3)
  
  DEALLOCATE(transformA)
  DEALLOCATE(transformB)


! ==================================================================== !
! EXAMPLE 4: interpolate: f(x,y) = exp(-x^2) * cos(y)
! with a rule that exactly interpolates polynomials of total degree

  gridID = tsgNewGridID()
  
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Example 4: interpolate f(x,y) = exp(-x^2) * cos(y), using clenshaw-curtis iptotal rule"
  WRITE(*,*)
  
  dims = 2
  outs = 1
  level = 10
  
  desired_x(1) = 0.3
  desired_x(2) = 0.7
  
  ! desired value
  exact = exp(-desired_x(1)**2) * cos(desired_x(2))
  
  ! iptotal = 3, clenshaw-curtis = 1
  CALL tsgMakeGlobalGrid(gridID, dims, outs, level, 3, 1)
  
  N = tsgGetNumNeeded(gridID)
  points => tsgGetNeededPoints(gridID)
  ALLOCATE(values(outs,N))
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    values(1,i) = exp(-x**2) * cos(y)
  END DO
  
  CALL tsgLoadNeededPoints(gridID, values)
  DEALLOCATE(values)
  DEALLOCATE(points)
  
  ALLOCATE(res(outs)) ! will DEALLOCATE later
  CALL tsgEvaluate(gridID, desired_x, res)
  E = abs(res(1) - exact)
  
  WRITE(*,"(A,I4)")   "  using polynomials of total degree:  ", level
  WRITE(*,"(A,I4,A)") "      the grid has:                   ", N, " points"
  WRITE(*,"(A,E25.16)") "      interpolant at (0.3,0.7):    ", integ
  WRITE(*,"(A,E25.16)") "      error:                       ", E
  WRITE(*,*)
  
  ! do the same with level = 12
  level = 12
  
  ! iptotal = 3, clenshaw-curtis = 1
  CALL tsgMakeGlobalGrid(gridID, dims, outs, level, 3, 1)
  
  N = tsgGetNumNeeded(gridID)
  points => tsgGetNeededPoints(gridID)
  ALLOCATE(values(outs,N))
  
  DO i = 1, N
    x = points(1, i)
    y = points(2, i)
    values(1,i) = exp(-x**2) * cos(y)
  END DO
  
  CALL tsgLoadNeededPoints(gridID, values)
  DEALLOCATE(values)
  DEALLOCATE(points)
  
  CALL tsgEvaluate(gridID, desired_x, res)
  E = abs(res(1) - exact)
  DEALLOCATE(res)
  
  WRITE(*,"(A,I4)")   "  using polynomials of total degree:  ", level
  WRITE(*,"(A,I4,A)") "      the grid has:                   ", N, " points"
  WRITE(*,"(A,E25.16)") "      interpolant at (0.3,0.7):    ", integ
  WRITE(*,"(A,E25.16)") "      error:                       ", E
  WRITE(*,*)

! ==================================================================== !
! prepare random smaples for future tests
  call srand(TIME())

  DO i = 1, 1000
    DO j = 1, 4
      randPoints(j,i) = rand()
    END DO
  END DO

! ==================================================================== !
! EXAMPLE 5:
! interpolate: f(x1,x2,x3,x4) = exp(-x1^2) * cos(x2) * exp(-x3^2) * cos(x4)
! with Global and Sequence Leja rules
  
  dims = 4
  outs = 1
  level = 15
  
  ! 8: rule leja,    1: type level
  CALL cpu_time(cpuStart)
  CALL tsgMakeGlobalGrid(gridID, dims, outs, level, 1, 8)
  CALL cpu_time(cpuEnd)
  stages(1,1) = cpuEnd - cpuStart
  
  N = tsgGetNumPoints(gridID)
  
  WRITE(*,*) "-------------------------------------------------------------------------------------------------"
  WRITE(*,*) "Example 5: interpolate f(x1,x2,x3,x4) = exp(-x1^2) * cos(x2) * exp(-x3^2) * cos(x4)"
  WRITE(*,*) "       comparign the performance of Global and Sequence grids with leja nodes"
  WRITE(*,"(A,I4)") "       using polynomials of total degree up to: ", level
  WRITE(*,"(A,I4,A)") "      the grids have:                   ", N, " points"
  WRITE(*,*) "       both grids are evaluated at 1000 random points "
  WRITE(*,*)
  
  points => tsgGetNeededPoints(gridID)
  ALLOCATE(values(outs,N))
  DO i = 1, N
    values(1,i) = exp(-points(1,i)**2) * cos(points(2,i)) * exp(-points(3,i)**2) * cos(points(4,i))
  END DO
  DEALLOCATE(points)
  
  CALL cpu_time(cpuStart)
  CALL tsgLoadNeededPoints(gridID, values)
  CALL cpu_time(cpuEnd)
  stages(1,2) = cpuEnd - cpuStart
  
  ALLOCATE(res2(outs,1000)) ! 2-D result
  
  CALL cpu_time(cpuStart)
  CALL tsgEvaluateBatch(gridID, randPoints, 1000, res2)
  CALL cpu_time(cpuEnd)
  stages(1,3) = cpuEnd - cpuStart
  
  ! 8: rule leja,    1: type level
  CALL cpu_time(cpuStart)
  CALL tsgMakeSequenceGrid(gridID, dims, outs, level, 1, 8)
  CALL cpu_time(cpuEnd)
  stages(2,1) = cpuEnd - cpuStart
  
  ! points are the same, no need to recompue values
  CALL cpu_time(cpuStart)
  CALL tsgLoadNeededPoints(gridID, values)
  CALL cpu_time(cpuEnd)
  stages(2,2) = cpuEnd - cpuStart
  
  DEALLOCATE(values)
  
  CALL cpu_time(cpuStart)
  CALL tsgEvaluateBatch(gridID, randPoints, 1000, res2)
  CALL cpu_time(cpuEnd)
  stages(2,3) = cpuEnd - cpuStart
  
  WRITE(*,*) "Stage        Global Grid      Sequence Grid"
  WRITE(*,"(A,E20.8,E20.8)") " make grid  ", stages(1,1), stages(2,1)
  WRITE(*,"(A,E20.8,E20.8)") " load needed  ", stages(1,2), stages(2,2)
  WRITE(*,"(A,E20.8,E20.8)") " evaluate  ", stages(1,3), stages(2,3)
  WRITE(*,*) "WARNING: I have not figured out how to time execution under Fortran"
  
  DEALLOCATE(res2)
  
! no need to free grid IDs before tsgFinalize(),
! all memory will be freed regardless
! must deallocate points, weights, etc.
  CALL tsgFinalize()

END PROGRAM TasmanianSGExample
