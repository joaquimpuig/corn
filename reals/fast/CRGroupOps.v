(*
Copyright © 2006-2008 Russell O’Connor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)

Require Import QArith Qabs.
Require Import CoRN.metric2.Metric.
Require Import CoRN.metric2.UniformContinuity.
Require Import CoRN.model.totalorder.QposMinMax.
Require Export CoRN.model.metric2.CRmetric.
Require Import CoRN.model.totalorder.QMinMax.
Require Import CoRN.model.metric2.Qmetric.
Require Import CoRN.metric2.ProductMetric.
Require Import CoRN.stdlib_omissions.Pair.
Require Import MathClasses.interfaces.canonical_names.

(* Backwards compatibility for Hint Rewrite locality attributes *)
Set Warnings "-unsupported-attributes".

Set Implicit Arguments.
Set Automatic Introduction.

Opaque CR Qmin Qmax.

Local Open Scope Q_scope.
Local Open Scope uc_scope.

#[global]
Instance CR0: Zero CR := cast Q CR 0.
Notation "0" := (inject_Q_CR 0) : CR_scope.

#[global]
Instance CR1: One CR := cast Q CR 1.
Notation "1" := (inject_Q_CR 1) : CR_scope.

(**
** Addition
Lifting addition over [Q] by one parameter yields a rational translation
function. *)
Lemma Qtranslate_uc_prf (a:Q)
  : is_UniformlyContinuousFunction (fun b:Q => (a+b):Q) Qpos2QposInf.
Proof.
 intros e b0 b1 H.
 simpl in *.
 unfold Qball in *.
 unfold QAbsSmall.
 setoid_replace (a + b0 - (a + b1)) with (b0 - b1)%Q.
 apply H. ring_simplify. reflexivity.
Qed.

Definition Qtranslate_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (Qtranslate_uc_prf a).
Transparent CR.
Definition translate (a:Q) : CR --> CR := Cmap QPrelengthSpace (Qtranslate_uc a).

Lemma translate_ident : forall x:CR, (translate 0 x==x)%CR.
Proof.
 intros x.
 unfold translate.
 assert (H:msp_eq (Qtranslate_uc 0) (uc_id _)).
 apply ucEq_equiv.
  intros a.
  simpl.
  rewrite Qplus_0_l.
  reflexivity.
 simpl.
 intros e1 e2. destruct x; simpl.
 rewrite Qplus_0_r.
 rewrite Qplus_0_l. apply regFun_prf.
Qed. 

(** Lifting translate yields binary addition over CR. *)
Lemma Qplus_uc_prf :  is_UniformlyContinuousFunction Qtranslate_uc Qpos2QposInf.
Proof.
 intros e a0 a1 H. split. apply Qpos_nonneg. intro b.
 simpl in *.
 do 2 rewrite -> (fun x => Qplus_comm x b).
 apply Qtranslate_uc_prf.
 assumption.
Qed.

Definition Qplus_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qplus_uc_prf.


(** Finally, CRplus: *)

Definition CRplus_uc : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qplus_uc.
#[global]
Instance CRplus: Plus CR := ucFun2 CRplus_uc.
Notation "x + y" := (ucFun2 CRplus_uc x y) : CR_scope.

Lemma CRplus_translate : forall (a:Q) (y:CR), (' a + y == translate a y)%CR.
Proof.
 intros a y.
 unfold ucFun2, CRplus.
 unfold Cmap2.
 unfold inject_Q_CR.
 simpl. intros e1 e2. simpl.
 unfold Cap_raw. simpl. destruct y; simpl.
 simpl. split.
 - ring_simplify.
   destruct (regFun_prf ((1#2)*e1)%Qpos e2) as [H _].
   simpl in H.
   refine (Qle_trans _ _ _ _ H).
   ring_simplify. apply Qplus_le_l.
   apply Qmult_le_r. apply Qpos_ispos. discriminate.
 - ring_simplify.
   destruct (regFun_prf ((1#2)*e1)%Qpos e2) as [_ H].
   apply (Qle_trans _ _ _ H). 
   apply Qplus_le_l. simpl. rewrite <- (Qmult_1_l (` e1)) at 2.
   apply Qmult_le_r. apply Qpos_ispos. discriminate.
Qed.

#[global]
Hint Rewrite CRplus_translate : CRfast_compute.

Lemma translate_Qplus : forall a b:Q, (translate a ('b)=='(a+b)%Q)%CR.
Proof.
 intros a b.
 unfold translate, Cmap.
 setoid_rewrite -> Cmap_fun_correct.
 apply MonadLaw3.
Qed.

#[global]
Hint Rewrite translate_Qplus : CRfast_compute.
(**
** Negation
Lifting negation on [Q] yields negation on CR.
*)
Lemma Qopp_uc_prf : @is_UniformlyContinuousFunction
                      Q_as_MetricSpace Q_as_MetricSpace Qopp Qpos2QposInf.
Proof.
 intros e a b H.
 simpl in *.
 unfold Qball in *.
 apply QAbsSmall_opp in H.
 unfold QAbsSmall.
 setoid_replace (-a - - b) with (-(a-b)).
 apply H. ring_simplify. reflexivity.
Qed.

Definition Qopp_uc : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qopp_uc_prf.

#[global]
Instance CRopp: Negate CR := Cmap QPrelengthSpace Qopp_uc.

Notation "- x" := (CRopp x) : CR_scope.

(**
** Subtraction
There is no subtraction on CR.  It is simply notation for adding a
negated quantity.  This way all lemmas about addition automatically
apply to subtraction.
*)
Notation "x - y" := (x + (- y))%CR : CR_scope.
(* begin hide *)
Add Morphism CRopp with signature (@msp_eq _) ==> (@msp_eq _) as CRopp_wd.
Proof.
 apply uc_wd.
Qed.
(* end hide *)
(**
** Inequality
First a predicate for nonnegative numbers is defined. *)
Definition CRnonNeg (x:CR) := forall e:Qpos, (-proj1_sig e) <= (approximate x e).
(* begin hide *)
Add Morphism CRnonNeg with signature (@msp_eq _) ==> iff as CRnonNeg_wd.
Proof.
 assert (forall x1 x2 : RegularFunction Qball,
            regFunEq x1 x2 -> CRnonNeg x1 -> CRnonNeg x2).
  intros x y Hxy Hx e.
  apply Qnot_lt_le.
  intros He.
  rewrite ->  Qlt_minus_iff in He.
  pose (e' := exist _ _ He).
  pose (H1:=(Hx ((1#3)*e')%Qpos)).
  pose (H2:=(Hxy ((1#3)*e')%Qpos e)).
  destruct H2 as [_ H2].
  change (approximate x ((1 # 3) * e')%Qpos - approximate y e
          <= proj1_sig ((1 # 3) * e' + e)%Qpos) in H2.
  rewrite -> Qle_minus_iff in H1.
  rewrite -> Qle_minus_iff in H2.
  autorewrite with QposElim in *.
  ring_simplify in H1.
  ring_simplify in H2.
  assert (0+0<=(approximate x ((1 # 3) * e')%Qpos + (1 # 3) * proj1_sig e')
              + ((1 # 3) * proj1_sig e' + proj1_sig e + (-1 # 1) * approximate x ((1 # 3) * e')%Qpos + approximate y e)) as H3.
  apply Qplus_le_compat; assumption.
  ring_simplify in H3.
  setoid_replace ((6 # 9) * proj1_sig e' + proj1_sig e + approximate y e)
    with ((6#9)* proj1_sig e' - proj1_sig e') in H3.
   ring_simplify in H3.
   apply (Qle_not_lt _ _ H3).
   rewrite -> Qlt_minus_iff.
   ring_simplify.
   apply (Qpos_ispos ((3#9)*e')).
   unfold e'. simpl. ring_simplify. reflexivity.
 intros.
 split.
  apply H, regFunEq_equiv; assumption.
 apply H.
 apply regFunEq_equiv.
 symmetry.
 assumption.
Qed.
(* end hide *)
(** And similarly for nonpositive. *)
Definition CRnonPos (x:CR) := forall e:Qpos, (approximate x e) <= proj1_sig e.
(* begin hide *)
Add Morphism CRnonPos with signature (@msp_eq _) ==> iff as CRnonPos_wd.
Proof.
 assert (forall x1 x2 : RegularFunction Qball,
            regFunEq x1 x2 -> CRnonPos x1 -> CRnonPos x2).
  intros x y Hxy Hx e.
  apply Qnot_lt_le.
  intros He.
  rewrite -> Qlt_minus_iff in He.
  pose (e' := exist _ _ He).
  pose (H1:=(Hx ((1#3)*e')%Qpos)).
  pose (H2:=(Hxy ((1#3)*e')%Qpos e)).
  destruct H2 as [H2 _].
  change (-proj1_sig ((1 # 3) * e' + e)%Qpos
          <= approximate x ((1 # 3) * e')%Qpos - approximate y e) in H2.
  rewrite -> Qle_minus_iff in H1.
  rewrite -> Qle_minus_iff in H2.
  simpl in *.
  ring_simplify in H1.
  ring_simplify in H2.
  assert (H3: 0+0<=((1 # 3) * proj1_sig e' + (-1 # 1) * approximate x ((1 # 3) * e')%Qpos)
                  +(approximate x ((1 # 3) * e')%Qpos + (-1 # 1) * approximate y e + (1 # 3) * proj1_sig e' + proj1_sig e)).
  apply Qplus_le_compat. simpl. ring_simplify. assumption.
  simpl. ring_simplify. assumption.
  ring_simplify in H3.
  setoid_replace ((6 # 9) * proj1_sig e' + (-1 # 1) * approximate y e + proj1_sig e)
    with ((6#9)*proj1_sig e'-proj1_sig e') in H3.
   ring_simplify in H3.
   apply (Qle_not_lt _ _ H3).
   rewrite -> Qlt_minus_iff.
   ring_simplify.
   apply (Qpos_ispos ((3#9)*e')).
   unfold e'. simpl. ring_simplify. reflexivity.
 intros.
 split.
  apply H, regFunEq_equiv; assumption.
 apply H.
 apply regFunEq_equiv.
 symmetry.
 assumption.
Qed.
(* end hide *)
(** Inequality is defined in terms of nonnegativity. *)
#[global]
Instance CRle: Le CR := λ x y, (CRnonNeg (y - x))%CR.
Infix "<=" := CRle : CR_scope.

(* begin hide *)
Add Morphism CRle with signature (@msp_eq _) ==> (@msp_eq _) ==> iff as CRle_wd.
Proof.
 intros x1 x2 Hx y1 y2 Hy.
 change (x1==x2)%CR in Hx.
 change (y1==y2)%CR in Hy.
 unfold CRle.
 apply CRnonNeg_wd.
 apply ucFun2_wd.
  assumption.
 apply CRopp_wd.
 assumption.
Qed.
(* end hide *)
(** Basic properties of inequality *)
Lemma CRle_refl : forall x, (x <= x)%CR.
Proof.
 intros x e.
 simpl.
 unfold Cap_raw.
 simpl.
 rewrite -> Qle_minus_iff.
 ring_simplify.
 apply Qlt_le_weak. destruct e; exact q.
Qed.

Lemma CRle_antisym : forall x y, (x==y <-> (x <= y /\ y <= x))%CR.
Proof.
 intros x y.
 split;[intros H;rewrite -> H;split; apply CRle_refl|].
 intros [H1 H2].
 rewrite <- (doubleSpeed_Eq x).
 rewrite <- (doubleSpeed_Eq y).
 apply regFunEq_equiv, regFunEq_e.
 intros e.
 apply ball_weak. apply Qpos_nonneg.
 split;[apply H2|].
 specialize (H1 e).
 apply Qopp_le_compat in H1. rewrite Qopp_involutive in H1.
 refine (Qle_trans _ _ _ _ H1).
 simpl. unfold Cap_raw. simpl.
 ring_simplify. apply Qle_refl.
Qed.

Lemma CRle_trans : forall x y z, (x <= y -> y <= z -> x <= z)%CR.
Proof.
 intros x y z H1 H2.
 unfold CRle.
 rewrite <- (doubleSpeed_Eq (z-x)%CR).
 intros e.
 assert (H1':=H1 ((1#2)*e)%Qpos).
 assert (H2':=H2 ((1#2)*e)%Qpos).
 clear H1 H2.
 simpl in *.
 unfold Cap_raw in *.
 simpl in *.
 apply (Qle_trans _ ((approximate z ((1 # 2) * ((1 # 2) * e))%Qpos
   - approximate y ((1 # 2) * ((1 # 2) * e))%Qpos + (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos
                                                     - approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)))).
 2: ring_simplify; apply Qle_refl.
 apply (Qle_trans _ (-(1#2)*proj1_sig e + - (1#2)* proj1_sig e)).
 ring_simplify. apply Qmult_le_r. apply Qpos_ispos. discriminate.
 apply Qplus_le_compat; apply (Qle_trans _ (- ((1 # 2) * ` e))).
 destruct e. simpl. ring_simplify. apply Qle_refl. assumption.
 destruct e. simpl. ring_simplify. apply Qle_refl. assumption.
Qed.

(**
** Maximum
[QboundBelow] ensures that a real number is at least some fixed
rational number.  It is the lifting of the first parameter of [Qmax].
*)
Lemma QboundBelow_uc_prf (a:Q)
  : is_UniformlyContinuousFunction (fun b:Q => (Qmax a b):Q) Qpos2QposInf.
Proof.
 intros e b0 b1 H.
 simpl in *.
 assert (X:forall a b0 b1, Qball (proj1_sig e) b0 b1
                      -> b0 <= a <= b1 -> Qball (proj1_sig e) a b1).
  clear a b0 b1 H.
  intros a b0 b1 H [H1 H2].
  unfold Qball in *.
  unfold QAbsSmall in *.
  split.
   apply Qle_trans with (b0-b1).
   apply H.
   apply Qplus_le_l.
   assumption.
  apply Qle_trans with 0.
  apply (Qplus_le_l _ _ b1).
  ring_simplify. assumption.
  apply Qpos_nonneg.
 do 2 apply Qmax_case; intros H1 H2.
    apply ball_refl. apply Qpos_nonneg.
   eapply X.
    apply H.
   tauto.
  apply ball_sym.
  apply X with b1.
   apply ball_sym.
   apply H.
  tauto.
 assumption.
Qed.

Definition QboundBelow_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (QboundBelow_uc_prf a).

Definition boundBelow (a:Q) : CR --> CR := Cmap QPrelengthSpace (QboundBelow_uc a).

(** CRmax is the lifting of [QboundBelow]. *)
Lemma Qmax_uc_prf :  is_UniformlyContinuousFunction QboundBelow_uc Qpos2QposInf.
Proof.
 intros e a0 a1 H. split. apply Qpos_nonneg. intro b.
 simpl in *.
 do 2 rewrite -> (fun x => Qmax_comm x b).
 apply QboundBelow_uc_prf.
 assumption.
Qed.

Definition Qmax_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qmax_uc_prf.

Definition CRmax : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qmax_uc.

Lemma Qmax_contract : forall (a b c : Q),
    Qabs (Qmax a b - Qmax a c) <= Qabs (b - c).
Proof.
  intros. apply Qabs_Qle_condition. split.
  - apply Qmax_case.
    + intros. apply Qmax_case. intros.
      unfold Qminus. rewrite Qplus_opp_r. apply (Qopp_le_compat 0).
      apply Qabs_nonneg. intros. rewrite Qabs_neg, Qopp_involutive.
      apply Qplus_le_l, H. apply (Qplus_le_l _ _ c).
      ring_simplify. exact (Qle_trans _ _ _ H H0).
    + intros. apply Qmax_case. intros.
      apply (Qle_trans _ 0). apply (Qopp_le_compat 0).
      apply Qabs_nonneg.
      unfold Qminus. rewrite <- Qle_minus_iff. exact H.
      intros. setoid_replace (b-c)%Q with (-(c-b)).
      apply Qopp_le_compat. rewrite Qabs_opp. apply Qle_Qabs.
      unfold equiv, stdlib_rationals.Q_eq. ring.
  - apply Qmax_case.
    + intros. apply Qmax_case. intros.
      unfold Qminus. rewrite Qplus_opp_r. 
      apply Qabs_nonneg. intros.
      apply (Qle_trans _ 0).
      apply (Qplus_le_l _ _ c). ring_simplify. exact H0.
      apply Qabs_nonneg.
    + intros. apply Qmax_case. intros.
      rewrite Qabs_pos. apply Qplus_le_r, Qopp_le_compat, H0.
      unfold Qminus. rewrite <- Qle_minus_iff.
      exact (Qle_trans _ _ _ H0 H). 
      intros. apply Qle_Qabs.
Qed.

Lemma CRmax_boundBelow : forall (a:Q) (y:CR), (CRmax (' a) y == boundBelow a y)%CR.
Proof.
 intros a y.
 unfold ucFun2, CRmax.
 unfold Cmap2.
 unfold inject_Q_CR.
 intros e1 e2.
 destruct y; simpl; unfold Cmap_fun, Cap_fun, Cap_raw; simpl.
 specialize (regFun_prf ((1 # 2) * e1)%Qpos e2).
 apply AbsSmall_Qabs.
 apply (Qle_trans _ _ _ (Qmax_contract _ _ _)).
 apply AbsSmall_Qabs in regFun_prf.
 apply (Qle_trans _ _ _ regFun_prf).
 apply Qplus_le_l. simpl.
 rewrite <- (Qmult_1_l (proj1_sig e1)) at 2.
 rewrite Qplus_0_r.
 apply Qmult_le_r. apply Qpos_ispos. discriminate.
Qed.

(** Basic properties of CRmax. *)
Lemma CRmax_ub_l : forall x y, (x <= CRmax x y)%CR.
Proof.
 intros x y e.
 simpl.
 unfold Cap_raw.
 simpl.
 unfold Cap_raw.
 simpl.
 rewrite -> Qmax_plus_distr_l.
 eapply Qle_trans;[|apply Qmax_ub_l].
 cut (QAbsSmall (proj1_sig e) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos +
   - approximate x ((1 # 2) * e)%Qpos));[unfold QAbsSmall;tauto|].
 change (ball (proj1_sig e) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos) (approximate x ((1 # 2) * e)%Qpos)).
 eapply ball_weak_le;[|apply regFun_prf].
 simpl.
 rewrite -> Qle_minus_iff.
 ring_simplify.
 apply (Qpos_nonneg ((2#8)*e)).
Qed.

Lemma CRmax_ub_r : forall x y, (y <= CRmax x y)%CR.
Proof.
 intros y x e.
 simpl.
 unfold Cap_raw.
 simpl.
 unfold Cap_raw.
 simpl.
 rewrite -> Qmax_plus_distr_l.
 eapply Qle_trans;[|apply Qmax_ub_r].
 cut (QAbsSmall (proj1_sig e) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos +
   - approximate x ((1 # 2) * e)%Qpos));[unfold QAbsSmall;tauto|].
 change (ball (proj1_sig e) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos) (approximate x ((1 # 2) * e)%Qpos)).
 eapply ball_weak_le;[|apply regFun_prf].
 simpl.
 rewrite -> Qle_minus_iff.
 ring_simplify.
 apply (Qpos_nonneg ((2#8)*e)).
Qed.

Lemma CRmax_lub: forall x y z : CR, (x <= z -> y <= z -> CRmax x y <= z)%CR.
Proof.
 intros x y z Hx Hy.
 rewrite <- (doubleSpeed_Eq z) in * |- *.
 intros e.
 assert (Hx':=Hx ((1#2)*e)%Qpos).
 assert (Hy':=Hy ((1#2)*e)%Qpos).
 clear Hx Hy.
 simpl in *.
 unfold Cap_raw in *.
 simpl in *.
 unfold Cap_raw.
 simpl.
 apply (Qle_trans _ ((-(1#2)*proj1_sig e) + (- (1#2)*proj1_sig e))).
 ring_simplify. apply Qmult_le_r. apply Qpos_ispos. discriminate.
 apply (Qle_trans _ ((approximate z ((1#2)*((1 # 2) * e))%Qpos +
   - approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos) +
     (approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos
       - Qmax (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
         (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos)))).
 2: ring_simplify; apply Qle_refl.
 apply Qplus_le_compat.
 - apply (Qle_trans _ (- ((1 # 2) * ` e))).
   destruct e; simpl; ring_simplify; apply Qle_refl.
   cut (ball ((1#2)*proj1_sig e) (approximate z ((1#2)*((1 # 2) * e))%Qpos)
             (approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos)).
   intros [A B]. assumption.
 refine (ball_weak_le _ _ _ _ _). 2:apply regFun_prf.
 rewrite -> Qle_minus_iff.
 simpl. ring_simplify.
 apply (Qpos_nonneg ((8#64)*e)).
 - apply (Qle_trans _ (- ((1 # 2) * ` e))). 
   destruct e; simpl; ring_simplify; apply Qle_refl.
   apply Qmax_case; intros; assumption. 
Qed.
(**
** Minimum
[QboundAbove] ensures that a real number is at most some fixed
rational number.  It is the lifting of the first parameter of [Qmin].
*)
Lemma QboundAbove_uc_prf (a:Q)
  : is_UniformlyContinuousFunction (fun b:Q => (Qmin a b):Q) Qpos2QposInf.
Proof.
 intros e b0 b1 H.
 simpl in *.
 unfold Qball.
 unfold QAbsSmall.
 setoid_replace (Qmin a b0 - Qmin a b1)
   with ((Qmax (- a) (-b1)) - (Qmax (-a) (-b0))).
  apply QboundBelow_uc_prf.
  apply Qopp_uc_prf.
  apply ball_sym.
  assumption.
 unfold Qminus.
 simpl.
 rewrite -> Qmin_max_de_morgan.
 rewrite -> Qmax_min_de_morgan.
 repeat rewrite -> Qopp_involutive.
 ring_simplify. reflexivity.
Qed.

Definition QboundAbove_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (QboundAbove_uc_prf a).

Definition boundAbove (a:Q) : CR --> CR := Cmap QPrelengthSpace (QboundAbove_uc a).

(** CRmin is the lifting of [QboundAbove]. *)
Lemma Qmin_uc_prf :  is_UniformlyContinuousFunction QboundAbove_uc Qpos2QposInf.
Proof.
 intros e a0 a1 H. split. apply Qpos_nonneg. intro b.
 simpl in *.
 do 2 rewrite -> (fun x => Qmin_comm x b).
 apply QboundAbove_uc_prf.
 assumption.
Qed.

Definition Qmin_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qmin_uc_prf.

Definition CRmin : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qmin_uc.

Lemma CRmin_boundAbove : forall (a:Q) (y:CR), (CRmin (' a) y == boundAbove a y)%CR.
Proof.
 intros a y.
 unfold ucFun2, CRmin.
 unfold Cmap2.
 unfold inject_Q_CR.
 intros e1 e2.
 destruct y; simpl; unfold Cmap_fun, Cap_fun, Cap_raw; simpl.
 specialize (regFun_prf ((1 # 2) * e1)%Qpos e2).
 rewrite Qplus_0_r. split.
 - apply Qmin_case. intros. apply Qmin_case. intros.
   unfold Qminus. rewrite Qplus_opp_r. apply (Qopp_le_compat 0).
   apply (Qpos_nonneg (e1+e2)). intros.
   intros. apply (Qle_trans _ 0). apply (Qopp_le_compat 0), (Qpos_nonneg (e1+e2)).
   unfold Qminus. rewrite <- Qle_minus_iff. exact H0. intros.
   apply (Qle_trans _ (approximate ((1 # 2)%Q ↾ eq_refl * e1)%Qpos - approximate e2)).
   destruct regFun_prf as [H1 _].
   refine (Qle_trans _ _ _ _ H1). simpl. ring_simplify.
   apply Qplus_le_l. apply Qmult_le_r. apply Qpos_ispos. discriminate.
   apply Qplus_le_r. apply Qopp_le_compat.
   apply Qmin_case. intros. exact H0. intros. apply Qle_refl.
 - apply Qmin_case. apply Qmin_case. intros.
   unfold Qminus. rewrite Qplus_opp_r. apply (Qpos_nonneg (e1+e2)).
   intros. apply (Qle_trans _ (approximate ((1 # 2) * e1)%Qpos - approximate e2)).
   apply Qplus_le_l, H0. destruct regFun_prf as [_ H1].
   apply (Qle_trans _ _ _ H1). apply Qplus_le_l. simpl.
   rewrite <- (Qmult_1_l (proj1_sig e1)) at 2.
   apply Qmult_le_r. apply Qpos_ispos. discriminate.
   intros. apply Qmin_case. 
   intros. apply (Qle_trans _ 0).
   apply (Qplus_le_l _ _ a). ring_simplify. exact H.
   apply (Qpos_nonneg (e1+e2)). intros.
   destruct regFun_prf as [_ H1].
   apply (Qle_trans _ _ _ H1). apply Qplus_le_l. simpl.
   rewrite <- (Qmult_1_l (proj1_sig e1)) at 2.
   apply Qmult_le_r. apply Qpos_ispos. discriminate.
Qed.

(** Basic properties of CRmin. *)
Lemma CRmin_lb_l : forall x y, (CRmin x y <= x)%CR.
Proof.
 intros x y e.
 simpl.
 unfold Cap_raw.
 simpl.
 unfold Cap_raw.
 simpl.
 rewrite -> Qmin_max_de_morgan.
 rewrite -> Qmax_plus_distr_r.
 eapply Qle_trans;[|apply Qmax_ub_l].
 cut (QAbsSmall (proj1_sig e) (approximate x ((1 # 2) * e)%Qpos +
   - approximate x ((1 # 2) * ((1 # 2) * e))%Qpos));[unfold QAbsSmall;tauto|].
 change (ball (proj1_sig e) (approximate x ((1 # 2) * e)%Qpos) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)).
 eapply ball_weak_le;[|apply regFun_prf].
 simpl.
 rewrite -> Qle_minus_iff.
 ring_simplify.
 apply (Qpos_nonneg ((2#8)*e)).
Qed.

Lemma CRmin_lb_r : forall x y, (CRmin x y <= y)%CR.
Proof.
 intros y x e.
 simpl.
 unfold Cap_raw.
 simpl.
 unfold Cap_raw.
 simpl.
 rewrite -> Qmin_max_de_morgan.
 rewrite -> Qmax_plus_distr_r.
 eapply Qle_trans;[|apply Qmax_ub_r].
 cut (QAbsSmall (proj1_sig e) (approximate x ((1 # 2) * e)%Qpos +
   - approximate x ((1 # 2) * ((1 # 2) * e))%Qpos));[unfold QAbsSmall;tauto|].
 change (ball (proj1_sig e) (approximate x ((1 # 2) * e)%Qpos) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)).
 eapply ball_weak_le;[|apply regFun_prf].
 simpl.
 rewrite -> Qle_minus_iff.
 ring_simplify.
 apply (Qpos_nonneg ((2#8)*e)).
Qed.

Lemma CRmin_glb: forall x y z : CR, (z <= x -> z <= y -> z <= CRmin x y)%CR.
Proof.
 intros x y z Hx Hy.
 rewrite <- (doubleSpeed_Eq z) in * |- *.
 intros e.
 assert (Hx':=Hx ((1#2)*e)%Qpos).
 assert (Hy':=Hy ((1#2)*e)%Qpos).
 clear Hx Hy.
 simpl in *.
 unfold Cap_raw in *.
 simpl in *.
 unfold Cap_raw.
 simpl.
 apply (Qle_trans _ ((-(1#2)*proj1_sig e) + (- (1#2)*proj1_sig e))).
 ring_simplify. apply Qmult_le_r. apply Qpos_ispos. discriminate.
 apply (Qle_trans _ ((approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos +
   - approximate z ((1#2)*((1 # 2) * e))%Qpos) + (Qmin (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
     (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos) +
                                                  - approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos))).
 2: ring_simplify; rewrite Qplus_comm; apply Qle_refl.
 apply Qplus_le_compat.
 - apply (Qle_trans _ (- ((1 # 2) * ` e))).
   destruct e; simpl; ring_simplify; apply Qle_refl.
   cut (ball ((1#2)*proj1_sig e) (approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos)
             (approximate z ((1#2)*((1 # 2) * e))%Qpos)) ;[intros [A B]; assumption|].
 refine (ball_weak_le _ _ _ _ _). 2:apply regFun_prf.
 rewrite -> Qle_minus_iff.
 simpl.
 ring_simplify.
 apply (Qpos_nonneg ((8#64)*e)).
 - apply (Qle_trans _ (- ((1 # 2) * ` e))).
   destruct e; simpl; ring_simplify; apply Qle_refl.
   apply Qmin_case;intro;assumption.
Qed.

(* Non-curried equivalent version of addition. *)

Lemma Qplus_uc_uncurry : is_UniformlyContinuousFunction
                           (fun ab : ProductMS Q_as_MetricSpace
                                             Q_as_MetricSpace
                            => fst ab + snd ab)
                           (fun e => (1#2)*e)%Qpos.
Proof.
  intros e1 [a b] [c d] [H H0]. simpl.
  simpl in H, H0. apply AbsSmall_Qabs.
  setoid_replace (a + b - (c + d))%Q
    with (a - c + (b - d))
    by (unfold equiv, stdlib_rationals.Q_eq; ring).
  apply (Qle_trans _ _ _ (Qabs_triangle _ _)).
  apply (Qle_trans _ ((1#2)*`e1 + (1#2)*`e1)).
  apply Qplus_le_compat.
  - apply AbsSmall_Qabs in H. apply H.
  - apply AbsSmall_Qabs in H0. apply H0.
  - ring_simplify. apply Qle_refl.
Qed.

Definition Qplus_uncurry
  : ProductMS Q_as_MetricSpace Q_as_MetricSpace --> Q_as_MetricSpace
  := Build_UniformlyContinuousFunction Qplus_uc_uncurry.

Lemma CRplus_uncurry_eq : forall x y : CR,
    msp_eq (CRplus x y)
          (Cmap (ProductMS_prelength QPrelengthSpace QPrelengthSpace)
                Qplus_uncurry (undistrib_Complete (x,y))).
Proof.
  intros x y. unfold CRplus, ucFun2, CRplus_uc. 
  transitivity (Cmap2 QPrelengthSpace QPrelengthSpace (uc_curry Qplus_uncurry) x y).
  2: apply Cmap2_curry.
  apply Cap_wd. 2: reflexivity.
  apply Cmap_wd. 2: reflexivity.
  apply ucEq_equiv.
  split. apply Qle_refl.
  intros a. reflexivity.
Qed.
