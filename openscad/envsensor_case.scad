$fn=90;

cutout_wdh = [27,55,28];
sensorbase_d = 55;
bme680_funnel_wd = [18,25];
bme680_pcb_w = 4;
bme680_pcb_indent = 10;
bme680_pcb_throughhole_wh = [6,6];

pcb_holder_height = 11;

ccs811_pcb_w = 4;
ccs811_pcb_throughhole_whd = [22,8,10];
wall_w = 0.5;

tape_strip_w = 9;

corner_r = 3;

bme680_y_offset = cutout_wdh[1]+sensorbase_d-corner_r-bme680_pcb_w;
ccs811_y_offset = cutout_wdh[1]+sensorbase_d-corner_r-30;

difference()
{
  translate([corner_r,corner_r,0])
  {
  difference()
  {
    minkowski()
    {
      cube([
        cutout_wdh[0]+2*wall_w-corner_r,
        cutout_wdh[1]+sensorbase_d+2*wall_w-corner_r,
        cutout_wdh[2]
        ]);
      //cylinder(r=corner_r,h=1);
      sphere(r=corner_r);
    }
    translate([-500,-500,-1000])
      cube([1000,1000,1000]);
  }
  }

  translate([wall_w+corner_r/2,wall_w+corner_r/2,-2*wall_w])
  {
    difference()
    {
      cube([cutout_wdh[0],cutout_wdh[1]+sensorbase_d,cutout_wdh[2]]);
      for (yoff=[
          tape_strip_w,
          cutout_wdh[1]/2+tape_strip_w,
          ccs811_y_offset-0.5*ccs811_pcb_throughhole_whd[1],
          cutout_wdh[1]+sensorbase_d-2.5*bme680_pcb_throughhole_wh[1],
          ])
        translate([0,yoff-tape_strip_w,0])
          cube([cutout_wdh[0],tape_strip_w,3*wall_w]);
      for (yoff=[
          bme680_y_offset,
          ccs811_y_offset,
          ccs811_y_offset+ccs811_pcb_throughhole_whd[1],
          ])
        translate([
            0,
            yoff,
            cutout_wdh[2]-pcb_holder_height])
          cube([cutout_wdh[0],corner_r,pcb_holder_height]);
    }
  }

  translate([
    wall_w+corner_r/2+cutout_wdh[0]/2-bme680_pcb_throughhole_wh[0]/2,
    bme680_y_offset+corner_r,
    cutout_wdh[2]-5*wall_w]) {
    cube([bme680_pcb_throughhole_wh[0],bme680_pcb_throughhole_wh[1],cutout_wdh[2]]);
  }

  translate([
    wall_w+corner_r/2+cutout_wdh[0]/2-ccs811_pcb_throughhole_whd[0]/2,
    ccs811_y_offset+ccs811_pcb_throughhole_whd[1]-corner_r,
    cutout_wdh[2]-ccs811_pcb_throughhole_whd[2]]) {
    cube([ccs811_pcb_throughhole_whd[0],ccs811_pcb_throughhole_whd[1],cutout_wdh[2]]);
  }

  translate([
    wall_w+corner_r/2+cutout_wdh[0]/2,
    wall_w+corner_r/2+wall_w,
    7])
    rotate([90,0,0])
      cylinder(r=5,h=corner_r+2*wall_w);
}

module stupid_booblike_idea ()
{
  sphere_outer_r=50;
  cutout_sphere_r=10;

  difference()
  {
    scale([1,1,1])
      translate([cutout_wdh[0]/2,cutout_wdh[1]/2,0])
        sphere(r=sphere_outer_r);

    // cutout for senser peek-through
    translate([cutout_wdh[0]/2,cutout_wdh[1]/2,sphere_outer_r])
      sphere(r=cutout_sphere_r);

    translate([0,0,-0.01])
      cube(cutout_wdh);

    translate([-sphere_outer_r,-sphere_outer_r,-sphere_outer_r])
      cube([3*sphere_outer_r,3*sphere_outer_r,sphere_outer_r]);

  #
    translate([
        cutout_wdh[0]/2-bme680_pcb_throughhole_wh[0]/2,
        cutout_wdh[1]/2,
        0])
        cube([bme680_pcb_throughhole_wh[0],bme680_pcb_w,sphere_outer_r]);
    translate([
        cutout_wdh[0]/2-bme680_funnel_wd[0]/2,
        cutout_wdh[1]/2-bme680_funnel_wd[1]+bme680_pcb_w,
        0])
      {
        translate([0,0,-bme680_pcb_indent])
          cube([bme680_funnel_wd[0],bme680_funnel_wd[1],sphere_outer_r]);
      }
  }
}


