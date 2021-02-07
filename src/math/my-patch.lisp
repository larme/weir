(in-package :math)

;; expt return only real number
(declaim (inline rexpt))
(defun rexpt (b p)
  (declare #.*opt-settings* (double-float b p))
  #+sbcl (expt b p)
  #-sbcl (realpart (expt b p)))
