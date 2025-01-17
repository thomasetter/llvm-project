; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=bounds-checking -S | FileCheck %s
target datalayout = "e-p:64:64:64-p1:16:16:16-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

@.str = private constant [8 x i8] c"abcdefg\00"

@.str_as1 = private addrspace(1) constant [8 x i8] c"abcdefg\00"


declare noalias ptr @malloc(i64) nounwind allocsize(0)
declare noalias ptr @calloc(i64, i64) nounwind allocsize(0,1)
declare noalias ptr @realloc(ptr nocapture allocptr, i64) nounwind allocsize(1)

define void @f1() nounwind {
; CHECK-LABEL: @f1(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @malloc(i64 32)
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i64 2
; CHECK-NEXT:    store i32 3, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
;
  %1 = tail call ptr @malloc(i64 32)
  %idx = getelementptr inbounds i32, ptr %1, i64 2
  store i32 3, ptr %idx, align 4
  ret void
}

define void @f2() nounwind {
; CHECK-LABEL: @f2(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @malloc(i64 32)
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i64 8
; CHECK-NEXT:    br label [[TRAP:%.*]]
; CHECK:       2:
; CHECK-NEXT:    store i32 3, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5:[0-9]+]]
; CHECK-NEXT:    unreachable
;
  %1 = tail call ptr @malloc(i64 32)
  %idx = getelementptr inbounds i32, ptr %1, i64 8
  store i32 3, ptr %idx, align 4
  ret void
}

define void @f3(i64 %x) nounwind {
; CHECK-LABEL: @f3(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 4, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = tail call ptr @calloc(i64 4, i64 [[X]])
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds i32, ptr [[TMP2]], i64 8
; CHECK-NEXT:    [[TMP3:%.*]] = sub i64 [[TMP1]], 32
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i64 [[TMP1]], 32
; CHECK-NEXT:    [[TMP5:%.*]] = icmp ult i64 [[TMP3]], 4
; CHECK-NEXT:    [[TMP6:%.*]] = or i1 [[TMP4]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = or i1 false, [[TMP6]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[TRAP:%.*]], label [[TMP8:%.*]]
; CHECK:       8:
; CHECK-NEXT:    store i32 3, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = tail call ptr @calloc(i64 4, i64 %x)
  %idx = getelementptr inbounds i32, ptr %1, i64 8
  store i32 3, ptr %idx, align 4
  ret void
}

define void @store_volatile(i64 %x) nounwind {
; CHECK-LABEL: @store_volatile(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @calloc(i64 4, i64 [[X:%.*]])
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i64 8
; CHECK-NEXT:    store volatile i32 3, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
;
  %1 = tail call ptr @calloc(i64 4, i64 %x)
  %idx = getelementptr inbounds i32, ptr %1, i64 8
  store volatile i32 3, ptr %idx, align 4
  ret void
}

define void @f4(i64 %x) nounwind {
; CHECK-LABEL: @f4(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @realloc(ptr null, i64 [[X:%.*]]) #[[ATTR3:[0-9]+]]
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i64 8
; CHECK-NEXT:    [[TMP2:%.*]] = sub i64 [[X]], 32
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[X]], 32
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i64 [[TMP2]], 4
; CHECK-NEXT:    [[TMP5:%.*]] = or i1 [[TMP3]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = or i1 false, [[TMP5]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[TRAP:%.*]], label [[TMP7:%.*]]
; CHECK:       7:
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = tail call ptr @realloc(ptr null, i64 %x) nounwind
  %idx = getelementptr inbounds i32, ptr %1, i64 8
  %2 = load i32, ptr %idx, align 4
  ret void
}

define void @f5(i64 %x) nounwind {
; CHECK-LABEL: @f5(
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 0, [[X:%.*]]
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds [8 x i8], ptr @.str, i64 0, i64 [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = sub i64 8, [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 8, [[TMP1]]
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i64 [[TMP2]], 1
; CHECK-NEXT:    [[TMP5:%.*]] = or i1 [[TMP3]], [[TMP4]]
; CHECK-NEXT:    br i1 [[TMP5]], label [[TRAP:%.*]], label [[TMP6:%.*]]
; CHECK:       6:
; CHECK-NEXT:    [[TMP7:%.*]] = load i8, ptr [[IDX]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %idx = getelementptr inbounds [8 x i8], ptr @.str, i64 0, i64 %x
  %1 = load i8, ptr %idx, align 4
  ret void
}

define void @f5_as1(i64 %x) nounwind {
; CHECK-LABEL: @f5_as1(
; CHECK-NEXT:    [[X_C:%.*]] = trunc i64 [[X:%.*]] to i16
; CHECK-NEXT:    [[TMP1:%.*]] = add i16 0, [[X_C]]
; CHECK-NEXT:    [[IDX:%.*]] = getelementptr inbounds [8 x i8], ptr addrspace(1) @.str_as1, i64 0, i64 [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = sub i16 8, [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i16 8, [[TMP1]]
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i16 [[TMP2]], 1
; CHECK-NEXT:    [[TMP5:%.*]] = or i1 [[TMP3]], [[TMP4]]
; CHECK-NEXT:    br i1 [[TMP5]], label [[TRAP:%.*]], label [[TMP6:%.*]]
; CHECK:       6:
; CHECK-NEXT:    [[TMP7:%.*]] = load i8, ptr addrspace(1) [[IDX]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %idx = getelementptr inbounds [8 x i8], ptr addrspace(1) @.str_as1, i64 0, i64 %x
  %1 = load i8, ptr addrspace(1) %idx, align 4
  ret void
}

define void @f6(i64 %x) nounwind {
; CHECK-LABEL: @f6(
; CHECK-NEXT:    [[TMP1:%.*]] = alloca i128, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = load i128, ptr [[TMP1]], align 4
; CHECK-NEXT:    ret void
;
  %1 = alloca i128
  %2 = load i128, ptr %1, align 4
  ret void
}

define void @f7(i64 %x) nounwind {
; CHECK-LABEL: @f7(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 16, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = alloca i128, i64 [[X]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = sub i64 [[TMP1]], 0
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i64 [[TMP3]], 16
; CHECK-NEXT:    [[TMP5:%.*]] = or i1 false, [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = or i1 false, [[TMP5]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[TRAP:%.*]], label [[TMP7:%.*]]
; CHECK:       7:
; CHECK-NEXT:    [[TMP8:%.*]] = load i128, ptr [[TMP2]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = alloca i128, i64 %x
  %2 = load i128, ptr %1, align 4
  ret void
}

define void @f8() nounwind {
; CHECK-LABEL: @f8(
; CHECK-NEXT:    [[TMP1:%.*]] = alloca i128, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = alloca i128, align 8
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 undef, ptr [[TMP1]], ptr [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = load i128, ptr [[TMP3]], align 4
; CHECK-NEXT:    ret void
;
  %1 = alloca i128
  %2 = alloca i128
  %3 = select i1 undef, ptr %1, ptr %2
  %4 = load i128, ptr %3, align 4
  ret void
}

define void @f9(ptr %arg) nounwind {
; CHECK-LABEL: @f9(
; CHECK-NEXT:    [[TMP1:%.*]] = alloca i128, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 undef, ptr [[ARG:%.*]], ptr [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = load i128, ptr [[TMP2]], align 4
; CHECK-NEXT:    ret void
;
  %1 = alloca i128
  %2 = select i1 undef, ptr %arg, ptr %1
  %3 = load i128, ptr %2, align 4
  ret void
}

define void @f10(i64 %x, i64 %y) nounwind {
; CHECK-LABEL: @f10(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 16, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = alloca i128, i64 [[X]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = mul i64 16, [[Y:%.*]]
; CHECK-NEXT:    [[TMP4:%.*]] = alloca i128, i64 [[Y]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = select i1 undef, i64 [[TMP1]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = select i1 undef, ptr [[TMP2]], ptr [[TMP4]]
; CHECK-NEXT:    [[TMP7:%.*]] = sub i64 [[TMP5]], 0
; CHECK-NEXT:    [[TMP8:%.*]] = icmp ult i64 [[TMP7]], 16
; CHECK-NEXT:    [[TMP9:%.*]] = or i1 false, [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = or i1 false, [[TMP9]]
; CHECK-NEXT:    br i1 [[TMP10]], label [[TRAP:%.*]], label [[TMP11:%.*]]
; CHECK:       11:
; CHECK-NEXT:    [[TMP12:%.*]] = load i128, ptr [[TMP6]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = alloca i128, i64 %x
  %2 = alloca i128, i64 %y
  %3 = select i1 undef, ptr %1, ptr %2
  %4 = load i128, ptr %3, align 4
  ret void
}

define void @f11(ptr byval(i128) %x) nounwind {
; CHECK-LABEL: @f11(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, ptr [[X:%.*]], i64 16
; CHECK-NEXT:    br label [[TRAP:%.*]]
; CHECK:       2:
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, ptr [[TMP1]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = getelementptr inbounds i8, ptr %x, i64 16
  %2 = load i8, ptr %1, align 4
  ret void
}

define void @f11_as1(ptr addrspace(1) byval(i128) %x) nounwind {
; CHECK-LABEL: @f11_as1(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[X:%.*]], i16 16
; CHECK-NEXT:    br label [[TRAP:%.*]]
; CHECK:       2:
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, ptr addrspace(1) [[TMP1]], align 4
; CHECK-NEXT:    ret void
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = getelementptr inbounds i8, ptr addrspace(1) %x, i16 16
  %2 = load i8, ptr addrspace(1) %1, align 4
  ret void
}

define i64 @f12(i64 %x, i64 %y) nounwind {
; CHECK-LABEL: @f12(
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 1, [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = tail call ptr @calloc(i64 1, i64 [[X]])
; CHECK-NEXT:    [[DOTIDX:%.*]] = mul i64 [[Y:%.*]], 8
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 0, [[DOTIDX]]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i64, ptr [[TMP2]], i64 [[Y]]
; CHECK-NEXT:    [[TMP5:%.*]] = sub i64 [[TMP1]], [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp ult i64 [[TMP1]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ult i64 [[TMP5]], 8
; CHECK-NEXT:    [[TMP8:%.*]] = or i1 [[TMP6]], [[TMP7]]
; CHECK-NEXT:    [[TMP9:%.*]] = icmp slt i64 [[TMP3]], 0
; CHECK-NEXT:    [[TMP10:%.*]] = or i1 [[TMP9]], [[TMP8]]
; CHECK-NEXT:    br i1 [[TMP10]], label [[TRAP:%.*]], label [[TMP11:%.*]]
; CHECK:       11:
; CHECK-NEXT:    [[TMP12:%.*]] = load i64, ptr [[TMP4]], align 8
; CHECK-NEXT:    ret i64 [[TMP12]]
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
  %1 = tail call ptr @calloc(i64 1, i64 %x)
  %2 = getelementptr inbounds i64, ptr %1, i64 %y
  %3 = load i64, ptr %2, align 8
  ret i64 %3
}

define i64 @load_volatile(i64 %x, i64 %y) nounwind {
; CHECK-LABEL: @load_volatile(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @calloc(i64 1, i64 [[X:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, ptr [[TMP1]], i64 [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = load volatile i64, ptr [[TMP2]], align 8
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = tail call ptr @calloc(i64 1, i64 %x)
  %2 = getelementptr inbounds i64, ptr %1, i64 %y
  %3 = load volatile i64, ptr %2, align 8
  ret i64 %3
}

; PR17402
define void @f13() nounwind {
; CHECK-LABEL: @f13(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[ALIVE:%.*]]
; CHECK:       dead:
; CHECK-NEXT:    [[INCDEC_PTR:%.*]] = getelementptr inbounds i32, ptr [[INCDEC_PTR]], i64 1
; CHECK-NEXT:    [[L:%.*]] = load i32, ptr [[INCDEC_PTR]], align 4
; CHECK-NEXT:    br label [[ALIVE]]
; CHECK:       alive:
; CHECK-NEXT:    ret void
;
entry:
  br label %alive

dead:
  ; Self-refential GEPs can occur in dead code.
  %incdec.ptr = getelementptr inbounds i32, ptr %incdec.ptr, i64 1
  %l = load i32, ptr %incdec.ptr
  br label %alive

alive:
  ret void
}

; Check that merging sizes in a phi works.
; FIXME: bounds-checking thinks that %alloc has an underlying size of 0.
define i8 @f14(i1 %i) {
; CHECK-LABEL: @f14(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[I:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[A:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    [[G:%.*]] = getelementptr i8, ptr [[A]], i32 32
; CHECK-NEXT:    br label [[BB2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[ALLOC:%.*]] = phi ptr [ null, [[ENTRY:%.*]] ], [ [[G]], [[BB1]] ]
; CHECK-NEXT:    [[IND:%.*]] = phi i64 [ 0, [[ENTRY]] ], [ -4, [[BB1]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 0, [[IND]]
; CHECK-NEXT:    [[P:%.*]] = getelementptr i8, ptr [[ALLOC]], i64 [[IND]]
; CHECK-NEXT:    [[TMP1:%.*]] = sub i64 0, [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i64 0, [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[TMP1]], 1
; CHECK-NEXT:    [[TMP4:%.*]] = or i1 [[TMP2]], [[TMP3]]
; CHECK-NEXT:    br i1 [[TMP4]], label [[TRAP:%.*]], label [[TMP5:%.*]]
; CHECK:       5:
; CHECK-NEXT:    [[RET:%.*]] = load i8, ptr [[P]], align 1
; CHECK-NEXT:    ret i8 [[RET]]
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
entry:
  br i1 %i, label %bb1, label %bb2

bb1:
  %a = alloca [32 x i8]
  %g = getelementptr i8, ptr %a, i32 32
  br label %bb2

bb2:
  %alloc = phi ptr [ null, %entry ], [ %g, %bb1 ]
  %ind = phi i64 [ 0, %entry ], [ -4, %bb1 ]
  %p = getelementptr i8, ptr %alloc, i64 %ind
  %ret = load i8, ptr %p
  ret i8 %ret
}

; Check that merging offsets in a phi works.
define i8 @f15(i1 %i) {
; CHECK-LABEL: @f15(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A1:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    [[G1:%.*]] = getelementptr i8, ptr [[A1]], i32 100
; CHECK-NEXT:    br i1 [[I:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[A2:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    [[G2:%.*]] = getelementptr i8, ptr [[A2]], i32 16
; CHECK-NEXT:    br label [[BB2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i64 [ 100, [[ENTRY:%.*]] ], [ 16, [[BB1]] ]
; CHECK-NEXT:    [[ALLOC:%.*]] = phi ptr [ [[G1]], [[ENTRY]] ], [ [[G2]], [[BB1]] ]
; CHECK-NEXT:    [[TMP1:%.*]] = sub i64 32, [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i64 32, [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[TMP1]], 1
; CHECK-NEXT:    [[TMP4:%.*]] = or i1 [[TMP2]], [[TMP3]]
; CHECK-NEXT:    br i1 [[TMP4]], label [[TRAP:%.*]], label [[TMP5:%.*]]
; CHECK:       5:
; CHECK-NEXT:    [[RET:%.*]] = load i8, ptr [[ALLOC]], align 1
; CHECK-NEXT:    ret i8 [[RET]]
; CHECK:       trap:
; CHECK-NEXT:    call void @llvm.trap() #[[ATTR5]]
; CHECK-NEXT:    unreachable
;
entry:
  %a1 = alloca [32 x i8]
  %g1 = getelementptr i8, ptr %a1, i32 100
  br i1 %i, label %bb1, label %bb2

bb1:
  %a2 = alloca [32 x i8]
  %g2 = getelementptr i8, ptr %a2, i32 16
  br label %bb2

bb2:
  %alloc = phi ptr [ %g1, %entry ], [ %g2, %bb1 ]
  %ret = load i8, ptr %alloc
  ret i8 %ret
}
