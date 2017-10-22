      DOUBLE PRECISION FUNCTION D1MACH(I)

c  Double-precision machine constants (see R1MACH for documentation).

c  By default, returns values appropriate for a computer with IEEE 
c  arithmetic.  This is an abbreviated version of a routine widely
c  used for 20+ years by numerical analysts.  Most of the values in
c  the original version pertain to computers which went to computer
c  heaven years ago and are of little if any interest.
c 
c  If the values herein do not work for any reason, just look in
c  your Fortran manual for the correct values (usually in the part
c  discussing representations of numbers) and insert them. The exact
c  values are not that important; they can be a factor of 2-3 off
c  without causing any harm.

c  Only I = 1,2,4 is actually used by DISORT. 

c  This routine is superseded in Fortran-90 by the intrinsic numeric 
c  inquiry functions HUGE(1.D0), TINY(1.D0), and EPSILON(1.D0).

c  The original version can be found on NetLib (search by name):
c      http://www.netlib.org/
c ====================================================================

      INTEGER   I
c      EXTERNAL  ERRMSG

      IF( I.EQ.1 )  THEN
c         D1MACH = 2.3D-308
        D1MACH = TINY(1.D0)
      ELSE IF( I.EQ.2 )  THEN  
c         D1MACH = 1.7D+308
        D1MACH = HUGE(1.D0)
      ELSE IF( I.EQ.4 )  THEN  
c         D1MACH = 2.3D-16
        D1MACH = EPSILON(1.D0)
      ELSE
         print *,"Error! Bad input to d1mach"
         print *,"I=",I
         stop
      END IF

      RETURN
      END
