$fn=90;

wall_w = 1.5;

tape_strip_w = 9;
tape_strip_h = 0.3;

corner_r = 3;
pms5003_bax_wdh = [50,38,21];
bme680_pcb_wdh = [16,14,1.5];
ccs811_pcb_wdh = [20,14.5,1.5];
// How much space to hold a dupont connector in place:
dupont_connector_clearance = 2.9;


module top_rounded_cube(dim,r)
{
  difference()
  {
    translate([r,r,0])
    {
      minkowski()
      {
        cube([
            dim[0]-2*r,
            dim[1]-2*r,
            dim[2]-1*r
        ]);
        //cylinder(r=r,h=1);
        sphere(r=r);
      }
    }
    translate([-500,-500,-1000])
      cube([1000,1000,1000]);
  }
}

module case ()
{
  difference()
  {
    // Main box shape:
    top_rounded_cube([
        cutout_wdh[0]+2*wall_w+corner_r,
        cutout_wdh[1]+2*wall_w+corner_r,
        cutout_wdh[2]],corner_r);

    union() {
      translate([wall_w+corner_r/2,wall_w+corner_r/2,-wall_w-corner_r/2])
      {
        // Main cutout:
        top_rounded_cube([cutout_wdh[0],cutout_wdh[1],cutout_wdh[2]],corner_r/2);
      }
      translate([
          wall_w+corner_r/2+cutout_wdh[0]/2,
          wall_w+corner_r/2+wall_w,
          7])
        rotate([90,0,0]) {
        cylinder(r=5,h=corner_r+2*wall_w);
      }
    }
  }
}

module esp8266()
{
  % union()
  {
    // PCB:
    color("#333")
    {
      difference()
      {
        union()
        {
          translate([1,1,0])
            minkowski()
            {
              cube([25-2*1,48-2*1,0.01]);
              cylinder(r=1,h=1.5);
            }
        }
        for (xoff=[2,25-2])
          for (yoff=[2,48-2])
            translate([xoff,yoff,-0.01])
              cylinder(r=1.5,h=3);
      }
    }

    // PCB furniture:
    color("silver")
    {
      // Micro-USB plug:
      translate([(25-8)/2,-1,1.5])
        cube([8,5,2.5]);
      // Buttons:
      for (xoff=[5,25-5-2])
        translate([xoff,0,1.5])
          cube([2,4,2]);

      // MCU:
      translate([6.5,25.5,1.5])
        cube([12,15,3]);
    }

    // Pins:
    color("silver")
    {
      for (xoff=[0,25-2])
      translate([xoff,5,0])
        mirror([0,0,1])
          cube([2,33,8]);
    }

    // Pin clearance when using Dupont cables:
    color("#800")
    {
        for (xoff=[0,25-2])
        translate([xoff,5,-8])
        mirror([0,0,1])
          cube([2,33,10]);
    }
  }
}

module bme680()
{
  % union()
  {
    difference() {
      union() {
        // PCB:
        color("purple")
        {
          cube(bme680_pcb_wdh);
          translate([(16-5)/2,14,0])
            cube([5,4,1.5]);
        }
        // PCB furniture:
        color("silver")
        {
          // BME680 sensor itself:
          translate([(16-3)/2,14+0.5,1.5])
            cube([3,3,1]);
        }
        // Pins:
        color("silver")
        {
          translate([0,0,1.5])
            cube([16,2,8]);
        }
        // Pin clearance when using Dupont cables:
        color("#800")
        {
          translate([0,0,1.5+8])
            cube([16,2,14]);
        }
      }
      // holes:
      for (xoff=[2.5,16-2.5])
        translate([xoff,11.5,-0.01])
          cylinder(r=1,h=1.5+0.02);
    }
  }
}

module ccs881()
{
  % union()
  {
    difference() {
      union() {
        // PCB:
        color("purple")
        {
          cube(ccs811_pcb_wdh);
        }
        // PCB furniture:
        color("darkgrey")
        {
          // CCS811 sensor itself:
          translate([(20-3)/2,7,1.5])
            cube([3,4,1]);
        }
        // Pins:
        color("silver")
        {
          mirror([0,0,1])
            cube([20,2,8]);
        }
        // Pin clearance when using Dupont cables:
        color("#800")
        {
          translate([0,0,-8])
            mirror([0,0,1])
              cube([20,2,14]);
        }
      }
      for (xoff=[2,20-2])
        translate([xoff,14.5-2,-0.01])
        cylinder(r=1.5,h=3);
    }
  }
}

module pms5003()
{
  % union()
  {
    difference()
    {
      color("cyan")
      {
        translate([0.5,0.5,0.5])
        minkowski()
        {
          cube([
            pms5003_bax_wdh[0]-2*0.5,
            pms5003_bax_wdh[1]-2*0.5,
            pms5003_bax_wdh[2]-2*0.5]);
          sphere(r=0.5);
        }
      }
      translate([14,-0.01,21/2])
        rotate([-90,0,0])
          color("black")
          {
            difference() {
              cylinder(r=9,h=10);
              translate([0,0,-0.01]) {
                cylinder(r=6,h=10+0.02);
                cube([2,20,30],center=true);
                cube([20,2,30],center=true);
              }
            }
          }
      for (xoff=[31.5,35.5,39.5,43.5])
        translate([xoff,-0.01,2.5])
          color("black")
          {
            rotate([-90,0,0])
              cylinder(r=1,h=10+0.02);
            
          }
      translate([5,38+0.01,(21-5)/2])
        mirror([0,1,0])
        color("black")
        {
          cube([18,2,5]);
        }
    }
    // Cable clearance for ribbon cable
    translate([5,38,(21-3)/2])
      color("#800")
      {
      #
        cube([18,3,3]);
      }
  }
}


outer_case_wdh =
      [115,
      pms5003_bax_wdh[0]+0.5,
      28];

sensor_cutout_xoffs = [27,72];
sensor_cutout_depth = 20;

module case_with_pms5003()
{
  module sensor_cutout_pos()
  {
    cube([
      sensor_cutout_xoffs[1]-sensor_cutout_xoffs[0],
      sensor_cutout_depth,
      outer_case_wdh[2]-wall_w]);

    // long-bridged-roof-carrying "beams":
    for (xoff =[0,sensor_cutout_xoffs[1]-sensor_cutout_xoffs[0]])
      translate([xoff,0,outer_case_wdh[2]-2*wall_w])
        translate([0,0,wall_w])
          rotate([-90,0,0])
            cylinder(r=wall_w/2,h=outer_case_wdh[1]+wall_w);
  }
  module sensor_cutout_neg()
  {
    translate([wall_w,0,3])
      cube([bme680_pcb_wdh[0]+2,40,dupont_connector_clearance]);

    translate([
      sensor_cutout_xoffs[1]-sensor_cutout_xoffs[0]-(ccs811_pcb_wdh[0]+2)-wall_w,
      0,
      3])
      cube([ccs811_pcb_wdh[0]+2,40,dupont_connector_clearance]);

    translate([0,0,wall_w])
    cube([
      sensor_cutout_xoffs[1]-sensor_cutout_xoffs[0],
      10,
      22]);

    for (xoff=[5,15,25,35])
      for (zoff=[10,20])
        translate([xoff,-1*outer_case_wdh[1],zoff])
          rotate([-90,0,0])
            cylinder(r=3,h=3*outer_case_wdh[1]);
  }
  difference()
  {
    top_rounded_cube([
      outer_case_wdh[0]+2*wall_w,
      outer_case_wdh[1]+2*wall_w,
      outer_case_wdh[2]+0*wall_w],r=2);
    

    difference()
    {
      translate([wall_w,wall_w,-wall_w])
        top_rounded_cube([
          outer_case_wdh[0],
          outer_case_wdh[1],
          outer_case_wdh[2]],r=0.2);

      translate([sensor_cutout_xoffs[0],-0.01,-0.01])
        sensor_cutout_pos();
    }

    translate([sensor_cutout_xoffs[0],-0.01,-0.01])
      sensor_cutout_neg();

    // breathing holes for PMS5003:
    translate([outer_case_wdh[0],outer_case_wdh[1]-2.5-10,2.0+10])
      rotate([0,90,0])
      cylinder(r1=9,r2=12,h=3*wall_w);
    hull() {
      for (yoff=[1.5,5.5,9.5,13.5])
        translate([outer_case_wdh[0]+2*wall_w+0.01,yoff+6.5,20])
          {
            rotate([0,-90,0])
              cylinder(r2=1,r1=3,h=3*wall_w);
            
          }
    }

    // USB cable access port:
    translate([wall_w,-wall_w,8])
      cube([7,3*wall_w,12]);
  }

  // Add tape strips:
  for (xoff = [0, outer_case_wdh[0]-tape_strip_w])
    translate([wall_w+xoff,wall_w,0])
      cube([tape_strip_w,outer_case_wdh[1],tape_strip_h]);
}


case_with_pms5003();

translate ([5+wall_w,2,wall_w])
  rotate([0,-90,0])
  esp8266();
translate ([116,wall_w,wall_w])
  translate([0,pms5003_bax_wdh[0],pms5003_bax_wdh[2]])
  rotate([0,180,90])
  pms5003();
translate ([48,2,3])
  rotate([90,0,0])
  ccs881();
translate ([43,0,3])
  rotate([90,0,180])
  bme680();

