!==================================================================================================================================================================================
! Copyright (c) 2017, Miroslav Stoyanov
!
! This file is part of
! Toolkit for Adaptive Stochastic Modeling And Non-Intrusive ApproximatioN: TASMANIAN
!
! Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
!
! 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
!
! 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
!    and the following disclaimer in the documentation and/or other materials provided with the distribution.
!
! 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse
!    or promote products derived from this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
! IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
! OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
! OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
! UT-BATTELLE, LLC AND THE UNITED STATES GOVERNMENT MAKE NO REPRESENTATIONS AND DISCLAIM ALL WARRANTIES, BOTH EXPRESSED AND IMPLIED.
! THERE ARE NO EXPRESS OR IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, OR THAT THE USE OF THE SOFTWARE WILL NOT INFRINGE ANY PATENT,
! COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS, OR THAT THE SOFTWARE WILL ACCOMPLISH THE INTENDED RESULTS OR THAT THE SOFTWARE OR ITS USE WILL NOT RESULT IN INJURY OR DAMAGE.
! THE USER ASSUMES RESPONSIBILITY FOR ALL LIABILITIES, PENALTIES, FINES, CLAIMS, CAUSES OF ACTION, AND COSTS AND EXPENSES, CAUSED BY, RESULTING FROM OR ARISING OUT OF,
! IN WHOLE OR IN PART THE USE, STORAGE OR DISPOSAL OF THE SOFTWARE.
!==================================================================================================================================================================================
Module TasmanianSG
PUBLIC :: tsgInitialize,        &
          tsgFinalize,          &
          tsgNewGridID,         &
          tsgFreeGridID,        &
          tsgMakeGlobalGrid,    &
          tsgMakeSequenceGrid,  &
          tsgMakeLocalPolynomialGrid, &
          tsgMakeWaveletGrid,   &
          tsgCopyGrid,          &
          tsgUpdateGlobalGrid,  &
          tsgUpdateSequenceGrid,&
          tsgGetAlpha,          &
          tsgGetBeta,           &
          tsgGetOrder,          &
          tsgGetNumDimensions,  &
          tsgGetNumOutputs,     &
          tsgGetRule,           &
          tsgGetNumLoaded,      &
          tsgGetNumNeeded,      &
          tsgGetNumPoints,      &
          tsgGetLoadedPoints,   &
          tsgGetNeededPoints,   &
          tsgGetPoints,         &
          tsgGetLoadedPointsStatic,   &
          tsgGetNeededPointsStatic,   &
          tsgGetPointsStatic,         &
          tsgGetQuadratureWeights,          &
          tsgGetQuadratureWeightsStatic,    &
          tsgGetInterpolationWeights,       &
          tsgGetInterpolationWeightsStatic, &
!====== DO NOT USE THESE FUNCTIONS DIRECTLY =====!
!====== THESE ARE NEEDED TO LINK TO C++ =========!
          tsgReceiveInt,    &
          tsgReceiveScalar, &
          tsgReceiveVector, &
          tsgReceiveMatrix
PRIVATE
  INTEGER :: rows, cols, length, ival
  DOUBLE PRECISION :: dval
  DOUBLE PRECISION, pointer :: matrix(:,:), vector(:)
CONTAINS
!=======================================================================
SUBROUTINE tsgInitialize()
  CALL tsgbeg()
END SUBROUTINE tsgInitialize
!=======================================================================
SUBROUTINE tsgFinalize()
  CALL tsgend()
END SUBROUTINE tsgFinalize
!=======================================================================
FUNCTION tsgNewGridID() result(newid)
  INTEGER :: newid
  CALL tsgnew()
  newid = ival
END FUNCTION tsgNewGridID
!=======================================================================
SUBROUTINE tsgFreeGridID(gridID)
  INTEGER :: gridID
  CALL tsgfre()
END SUBROUTINE tsgFreeGridID
!=======================================================================
SUBROUTINE tsgMakeGlobalGrid(gridID, dims, outs, depth, gtype, rule, &
                             aweights, alpha, beta)
  INTEGER, intent(in) :: gridID, dims, outs, depth, gtype, rule
  INTEGER :: i
  INTEGER, optional :: aweights(*)
  DOUBLE PRECISION, optional :: alpha, beta
  DOUBLE PRECISION :: al, be
  INTEGER, allocatable :: aw(:)
  IF(PRESENT(alpha))then
    al = alpha
  else
    al = 0.0
  endif
  IF(PRESENT(beta))then
    be = beta
  else
    be = 0.0
  endif
  IF(PRESENT(aweights))then
    CALL tsgmg(gridID, dims, outs, depth, gtype, rule, aweights, al, be)
  ELSE
    ALLOCATE(aw(2*dims))
    DO i = 1, dims
      aw(i) = 1
    END DO
    DO i = dims+1, 2*dims
      aw(i) = 0
    END DO
    CALL tsgmg(gridID, dims, outs, depth, gtype, rule, aw, al, be)
    DEALLOCATE(aw)
  ENDIF
END SUBROUTINE tsgMakeGlobalGrid
!=======================================================================
SUBROUTINE tsgMakeSequenceGrid(gridID, dims, outs, depth, gtype, rule, &
                               aweights)
  INTEGER :: gridID, dims, outs, depth, gtype, rule
  INTEGER, optional :: aweights(*)
  INTEGER, allocatable :: aw(:)
  IF(PRESENT(aweights))then
    CALL tsgmg(gridID, dims, outs, depth, gtype, rule, aweights, al, be)
  ELSE
    ALLOCATE(aw(2*dims))
    DO i = 1, dims
      aw(i) = 1
    END DO
    DO i = dims+1, 2*dims
      aw(i) = 0
    END DO
    CALL tsgmg(gridID, dims, outs, depth, gtype, rule, aw, al, be)
    DEALLOCATE(aw)
  ENDIF
END SUBROUTINE tsgMakeSequenceGrid
!=======================================================================
SUBROUTINE tsgMakeLocalPolynomialGrid(gridID, dims, outs, depth, order,&
                                      rule)
  INTEGER :: gridID, dims, outs, depth
  INTEGER, optional :: order, rule
  INTEGER :: or, ru
  IF(PRESENT(order))then
    or = order
  ELSE
    or = 1
  ENDIF
  IF(PRESENT(rule))then
    ru = rule
  ELSE
    ru = 1
  ENDIF
  CALL tsgml(gridID, dims, outs, depth, or, ru)
END SUBROUTINE tsgMakeLocalPolynomialGrid
!=======================================================================
SUBROUTINE tsgMakeWaveletGrid(gridID, dims, outs, depth, order)
  INTEGER :: gridID, dims, outs, depth, or
  INTEGER, optional :: order
  IF(PRESENT(order))THEN
    or = order
  ELSE
    or = 1
  ENDIF
  CALL tsgmw(gridID, dims, outs, depth, or)
END SUBROUTINE tsgMakeWaveletGrid
!=======================================================================
SUBROUTINE tsgCopyGrid(gridID, sourceID)
  INTEGER :: gridID, sourceID
  CALL tsgcp(gridID, sourceID)
END SUBROUTINE tsgCopyGrid
!=======================================================================
SUBROUTINE tsgUpdateGlobalGrid(gridID, depth, gtype, aweights)
  INTEGER, intent(in) :: gridID, depth, gtype
  INTEGER, optional :: aweights(*)
  INTEGER, allocatable :: aw(:)
  INTEGER :: dims
  IF(PRESENT(aweights))THEN
    CALL tsgug(gridID, depth, gtype, aweights)
  ELSE
    dims = tsgGetNumDimensions(gridID)
    ALLOCATE(aw(2*dims))
    DO i = 1, dims
      aw(i) = 1
    END DO
    DO i = dims+1, 2*dims
      aw(i) = 0
    END DO
    CALL tsgug(gridID, depth, gtype, aw)
    DEALLOCATE(aw)
  ENDIF
END SUBROUTINE tsgUpdateGlobalGrid
!=======================================================================
SUBROUTINE tsgUpdateSequenceGrid(gridID, depth, gtype, aweights)
  INTEGER, intent(in) :: gridID, depth, gtype
  INTEGER :: dims
  INTEGER, optional :: aweights(*)
  INTEGER, allocatable :: aw(:)
  IF(PRESENT(aweights))THEN
    CALL tsgus(gridID, depth, gtype, aweights)
  ELSE
    dims = tsgGetNumDimensions(gridID)
    ALLOCATE(aw(2*dims))
    DO i = 1, dims
      aw(i) = 1
    END DO
    DO i = dims+1, 2*dims
      aw(i) = 0
    END DO
    CALL tsgus(gridID, depth, gtype, aw)
    DEALLOCATE(aw)
  ENDIF
END SUBROUTINE tsgUpdateSequenceGrid
!=======================================================================
FUNCTION tsgGetAlpha(gridID) result(alpha)
  INTEGER :: gridID
  DOUBLE PRECISION :: alpha
  CALL tsggal(gridID)
  alpha = dval
END FUNCTION tsgGetAlpha
!=======================================================================
FUNCTION tsgGetBeta(gridID) result(beta)
  INTEGER :: gridID
  DOUBLE PRECISION :: beta
  CALL tsggbe(gridID)
  beta = dval
END FUNCTION tsgGetBeta
!=======================================================================
FUNCTION tsgGetOrder(gridID) result(order)
  INTEGER :: gridID, order
  CALL tsggor(gridID)
  order = ival
END FUNCTION tsgGetOrder
!=======================================================================
FUNCTION tsgGetNumDimensions(gridID) result(dims)
  INTEGER :: gridID, dims
  CALL tsggnd(gridID)
  dims = ival
END FUNCTION tsgGetNumDimensions
!=======================================================================
FUNCTION tsgGetNumOutputs(gridID) result(outs)
  INTEGER :: gridID, outs
  CALL tsggno(gridID)
  outs = ival
END FUNCTION tsgGetNumOutputs
!=======================================================================
FUNCTION tsgGetRule(gridID) result(rule)
  INTEGER :: gridID, order
  CALL tsggor(gridID)
  rule = ival
END FUNCTION tsgGetRule
!=======================================================================
FUNCTION tsgGetNumLoaded(gridID) result(num)
  INTEGER :: gridID, num
  CALL tsggnl(gridID)
  num = ival
END FUNCTION tsgGetNumLoaded
!=======================================================================
FUNCTION tsgGetNumNeeded(gridID) result(num)
  INTEGER :: gridID, num
  CALL tsggnn(gridID)
  num = ival
END FUNCTION tsgGetNumNeeded
!=======================================================================
FUNCTION tsgGetNumPoints(gridID) result(num)
  INTEGER :: gridID, num
  CALL tsggnp(gridID, num)
END FUNCTION tsgGetNumPoints
!=======================================================================
FUNCTION tsgGetLoadedPoints(gridID) result(p)
  DOUBLE PRECISION, pointer :: p(:,:)
  INTEGER :: gridID
  CALL tsgglp(gridID)
  p => matrix
END FUNCTION tsgGetLoadedPoints
!=======================================================================
FUNCTION tsgGetNeededPoints(gridID) result(p)
  DOUBLE PRECISION, pointer :: p(:,:)
  INTEGER :: gridID
  CALL tsggdp(gridID)
  p => matrix
END FUNCTION tsgGetNeededPoints
!=======================================================================
FUNCTION tsgGetPoints(gridID) result(p)
  DOUBLE PRECISION, pointer :: p(:,:)
  INTEGER :: gridID
  CALL tsggpp(gridID)
  p => matrix
END FUNCTION tsgGetPoints
!=======================================================================
SUBROUTINE tsgGetLoadedPointsStatic(gridID, dims, points)
  INTEGER :: gridID, dims
  DOUBLE PRECISION :: points(dims,*)
  CALL tsggls(gridID, points)
END SUBROUTINE tsgGetLoadedPointsStatic
!=======================================================================
SUBROUTINE tsgGetNeededPointsStatic(gridID, dims, points)
  INTEGER :: gridID, dims
  DOUBLE PRECISION :: points(dims,*)
  CALL tsggds(gridID)
END SUBROUTINE tsgGetNeededPointsStatic
!=======================================================================
SUBROUTINE tsgGetPointsStatic(gridID, dims, points)
  INTEGER :: gridID, dims
  DOUBLE PRECISION :: points(dims,*)
  CALL tsggps(gridID)
END SUBROUTINE tsgGetPointsStatic
!=======================================================================
FUNCTION tsgGetQuadratureWeights(gridID) result(w)
  INTEGER :: gridID
  DOUBLE PRECISION, pointer :: w(:)
  CALL tsggqw(gridID)
  w => vector
END FUNCTION tsgGetQuadratureWeights
!=======================================================================
FUNCTION tsgGetQuadratureWeightsStatic(gridID, weights)
  INTEGER :: gridID
  DOUBLE PRECISION :: weights(*)
  CALL tsggqs(gridID)
END FUNCTION tsgGetQuadratureWeightsStatic
!=======================================================================
FUNCTION tsgGetInterpolationWeights(gridID, x) result(w)
  INTEGER :: gridID
  DOUBLE PRECISION :: x(*)
  DOUBLE PRECISION, pointer :: w(:)
  CALL tsggiw(gridID, x)
  w => vector
END FUNCTION tsgGetInterpolationWeights
!=======================================================================
FUNCTION tsgGetInterpolationWeightsStatic(gridID, x, weights)
  INTEGER :: gridID
  DOUBLE PRECISION :: x(*)
  DOUBLE PRECISION :: weights(*)
  CALL tsggis(gridID, x)
END FUNCTION tsgGetInterpolationWeightsStatic
!=======================================================================
! DO NOT CALL THOSE FUNCTIONS DIRECTLY !
!=======================================================================
SUBROUTINE tsgReceiveInt(i)
  INTEGER :: i
  ival = i
END SUBROUTINE tsgReceiveInt
!=======================================================================
SUBROUTINE tsgReceiveScalar(v)
  DOUBLE PRECISION :: v
  dval = v
END SUBROUTINE tsgReceiveScalar
!=======================================================================
SUBROUTINE tsgReceiveVector(s, V)
  INTEGER :: s
  DOUBLE PRECISION, target :: V(s)
  length = s
  vector => V(1:length)
END SUBROUTINE tsgReceiveVector
!=======================================================================
SUBROUTINE tsgReceiveMatrix(r, c, M)
  INTEGER :: r, c
  DOUBLE PRECISION, target :: M(r,c)
  rows = r
  cols = c
  matrix => M(1:rows,1:cols)
END SUBROUTINE tsgReceiveMatrix
!=======================================================================
END MODULE
