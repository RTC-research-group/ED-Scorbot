#include <stdio.h>
#include <math.h>

#define M_PI 3.14159265358979323846

/* Kinematics based on techreport "ON THE KINEMATICS OF THE SCORBOT ER-VII ROBOT"  
 by Laurenţiu PREDESCU and Ion STROE (2015)
 See: https://www.scientificbulletin.upb.ro/rev_docs_arhiva/fulld8b_273573.pdf
*/

double atan2 (double y, double x);
void inverse_kinematics (double x, double y, double z, double result[4]);

// Auxiliary function:
double atan2 (double y, double x) {
    if (x>0)
        return atan (y/x);
    else if (y>=0 && x<0)
        return atan (y/x) + M_PI;
    else if (y<0 && x<0)
        return atan (y/x) - M_PI;
    else if (y>0 && x==0)
        return (M_PI)/2;
    else if (y<0 && x==0)
        return (-M_PI)/2;
    else 
        return 0;
}

// (x,y,z) input positions are expressed in millimeters
// (θ1,θ2,θ3,θ4) Output angles are expressed in radians
void inverse_kinematics (double x, double y, double z, double result[4]) {
    // Distance are expressed in meters.
    double theta1, theta2, theta3, theta4;
	double term0, term0_bis, term1, term2, term3, term4, term5, term6;
    // Data is taken from Intelitek Scorbot ER VII user's manual (page 20) 
    double d1 = 0.358;  // Distance from base center (0,0,0) rotation (1) to shoulder/body center
    double a1 = 0.050;  // Distance from shoulder/body center to shoulder/body joint (2)
    double a2 = 0.300;  // Distance from shoulder/body joint to elbow/arm joint (3)
    double a3 = 0.250;  // Distance from elbow/arm joint to pitch/forearm joint (4)
    double d5 = 0.212;  // End efector (gripper) length 

    // theta1 (θ1) = base rotation angle (1)
    // theta2 (θ2) = shoulder/body rotation angle (2)
    // theta3 (θ3) = elbow/arm rotation angle (3)
    // theta4 (θ4) = pitch/forearm rotation angle (4)

    // theta1:
    theta1 = atan2 (y,x);

    // theta3:
    //theta3 =  acos ( (pow(sqrt(x*x+y*y) - a1 -d5, 2) + pow (z-d1, 2) - a2*a2 - a3*a3) / 2*a2*a3 );
    /**/
	term0 = sqrt(x*x+y*y);
	term0_bis = term0 - a1 -d5;
    term1 = pow(term0_bis, 2);
    term2 = pow (z-d1,2) - a2*a2 - a3*a3;
    term3 =  2*a2*a3;
    term4 = term1+term2;
    term5 = term4/term3;
    term6 = acos (term5);
    theta3 = term6;
    /**/

    // theta2:
    //theta2 =  atan2 (z-d1, sqrt(x*x + y*y) -a1 -d5) - atan2 (a3*sin(theta3), a2 + a3*cos (theta3));
    /**/
    term1 = z-d1;
    term2 = sqrt(x*x + y*y) -a1 -d5;
    term3 = a3*sin(theta3);
    term4 = a2 + a3*cos (theta3);
    term5 = atan2 (term1, term2);
    term6 = atan2 (term3, term4);
    theta2 = term5 - term6;
    /**/

    // theta4:
    theta4 = -theta2-theta3;

    result[0] = theta1;
    result[1] = theta2;
    result[2] = theta3;
    result[3] = theta4;
}


int main () {
	double x0, y0, z0, x1, y1, z1;
	double data0[4];
	double data1[4];
	
	x0 = 0.8119999999; 	// 0.812
	y0 = 0;
	z0 = 0.358;
		
	x1 = 0.750;
	y1 = 0;
	z1 = 0.300;
	
	inverse_kinematics (x0, y0, z0, data0);
	printf ("Scorbot angles for x0: %lf y0: %lf z0: %lf\n",  x0, y0, z0);
	printf ("[%lf, %lf, %lf, %lf] \n", data0[0], data0[1], data0[2], data0[3]);

	inverse_kinematics (x1, y1, z1, data1);
	printf ("Scorbot angles for x1: %lf y1: %lf z1: %lf\n",  x1, y1, z1);
	printf ("[%lf, %lf, %lf, %lf] \n", data1[0], data1[1], data1[2], data1[3]);
	

    return 0;
}

