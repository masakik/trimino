// Tri-Mos6 generator
// Copyright 2023 Chris Cogdon
// License: Creative Commons CC-BY-SA-4.0
// ...

set = 0; // [0:Base 1-5, 1:Base with 0, 2:Set with 6, 3:Reverse set, 4:Teste, 5:Box, 6:Cover]

trimo_side = 45;
trimo_height = 8; // [5:0.5:12]
trimo_corner_radius = 4;

/* [Numbers] */
number_enabled = true; // liga/desliga
trimo_text_font = "Liberation Sans";
trimo_text_size = 10;
trimo_text_relief = 0.6; // [0.2:0.2:1.0]
trimo_text_offset_factor = -0.35; // [-0.40:0.025:-0.25]
text_color = "red";

/* [Center] */
center_enabled = true; // liga/desliga
center_diameter = 5; // [1:8]
center_mode = "spherical_boss"; // [spherical_boss:Spherical Boss, spherical_cavity:Sphere cavity, cavity:Rebaixo cilíndrico]

/* [Border] */
border_enabled = true; // liga/desliga
border_thickness = 1.2; // [0.4:0.4:2.0]

/* [Paddings entre peças] */
trimo_padding_x = 2; // bem pertos
trimo_padding_y = 2;

/* [Rows and columns] */
trimo_printing_x = 9; // 9 por linha, cabe na Bambu A1
trimo_printing_y = 6; // Número de linhas

/* [Box] */
box_border = 4; // espessura da borda da caixa

include <pecas.scad>;

all_sets = [
  trimos_base_1_5,
  trimos_base_with_0,
  trimos_set_with_6,
  trimos_set_reverse,
  trimos_teste,
  "box",
  "cover",
];

// cantos arredondados usando offset
module triangle_scaled_rounded(side, corner_radius) {
  offset(r=corner_radius, $fn=80)
    offset(delta=-corner_radius)
      scale(side)
        polygon(
          [
            [-0.5, -0.5 * tan(30)],
            [0.5, -0.5 * tan(30)],
            [0, 0.5 * (tan(60) - tan(30))],
          ]
        );
}

module trimo(side, corner_radius, height) {
  linear_extrude(height)
    triangle_scaled_rounded(side, corner_radius);
}

module trimo_border(side, corner_radius) {
  translate([0, 0, trimo_height - 0.001]) {
    color(text_color)
      linear_extrude(trimo_text_relief + 0.001)
        difference() {
          triangle_scaled_rounded(side, corner_radius);
          offset(delta=-border_thickness)
            triangle_scaled_rounded(side, corner_radius);
        }
  }
}

module trimo_with_center() {
  if (center_enabled) {
    if (center_mode == "spherical_cavity") {
      difference() {
        trimo(trimo_side, trimo_corner_radius, trimo_height);
        translate([0, 0, trimo_height + center_diameter / 2 - trimo_text_relief])
          sphere(r=center_diameter / 2, $fn=80);
      }
    } else if (center_mode == "spherical_boss") {
      trimo(trimo_side, trimo_corner_radius, trimo_height);
      translate([0, 0, trimo_height - center_diameter / 2 + trimo_text_relief])
        sphere(r=center_diameter / 2, $fn=80);
    } else if (center_mode == "cavity") {
      difference() {
        trimo(trimo_side, trimo_corner_radius, trimo_height);
        translate([0, 0, trimo_height - 2])
          cylinder(h=trimo_height, r=center_diameter / 2, $fn=80);
      }
    }
  } else {
    trimo(trimo_side, trimo_corner_radius, trimo_height);
  }
}

module trimo_with_border() {
  trimo_with_center();
  if (border_enabled) {
    translate([0, 0, trimo_height - 0.001]) {
      linear_extrude(trimo_text_relief + 0.001)
        difference() {
          triangle_scaled_rounded(trimo_side, trimo_corner_radius);
          offset(delta=-border_thickness)
            triangle_scaled_rounded(trimo_side, trimo_corner_radius);
        }
    }
  }
}

module trimo_with_number(numbers) {
  trimo_with_border();
  if (number_enabled) {
    translate([0, 0, trimo_height]) {
      for (i = [0:2]) {
        rotate([0, 0, 120 * i - 60])
          translate([0, trimo_side * trimo_text_offset_factor, 0])
            color(text_color)
              linear_extrude(trimo_text_relief)
                text(str(numbers[i]), font=trimo_text_font, size=trimo_text_size, halign="center");
      }
    }
  }
}

module set_of_trimos(trimos) {
  for (y = [0:trimo_printing_y - 1]) {
    for (x = [0:trimo_printing_x - 1]) {
      trimo_index = x + trimo_printing_x * y;
      if (trimo_index < len(trimos)) {
        tx = x * (trimo_side * 0.5 + trimo_padding_x);
        ty = y * (trimo_side * 0.866 + trimo_padding_y) + (x % 2) * 0.289 * trimo_side;
        translate([tx, ty, 0])
          rotate([0, 0, 180 * (x % 2)])
            trimo_with_number(trimos[trimo_index]);
      }
    }
  }
}

module box_inside_trimos(n, flip, base_x, base_y, height) {
  trimo_scale = 1.0; // aumento 1% de folga entre peças
  for (i = [0:n]) {
    tx = i * trimo_side * trimo_scale * 0.5 + base_x;
    ty = ( (i + flip) % 2) * 0.2886 * trimo_side * trimo_scale + base_y;
    translate([tx, ty, 0])
      rotate([0, 0, 180 * ( (i + flip) % 2)])
        translate([0, 0, -0.01])
          trimo(trimo_side * trimo_scale, 0, height * 1.01);
  }
}

module box_inside(height) {
  // Cada linha: [n, flip, y_multiplier]
  lines = [
    [6, 1, 0],
    [6, 0, 1],
    [4, 0, 2],
    [2, 0, 3],
  ];

  for (row = lines) {
    n = row[0];
    flip = row[1];
    ymul = row[2];

    base_x = -(n) * trimo_side * 0.25;
    trimo_height = trimo_side * 0.8660254;
    first_offset = 1.33 * trimo_height;
    base_y = trimo_height * ymul * 0.9998 - first_offset;

    box_inside_trimos(n, flip, base_x, base_y, height);
  }
}

module box(set) {
  box_side = 5 * trimo_side * 1.02;
  corner_radius = 0.65 * trimo_side;
  // 5 camadas cheias + 8 peças de altura
  box_height_relief = 4; // espaço extra para facilitar a remoção
  // box_border = 4;
  box_height = 6 * (trimo_height + trimo_text_relief) + box_border + box_height_relief;

  //raio do limite de corte da tampa: na caixa corta para fora, na tampa corta para dentro
  cut_radius = (box_side + box_border) * 0.8225 * 0.5;

  // altura do corte que a tampa vai entrar na caixa
  cut_height = 20;

  // altura do encaixe da tampa na caixa
  locker_height = 4;

  // folga da tampa
  cover_clearance = 0.8;

  // chanfro da base
  chamfer_size = 2;

  // corte externo da caixa
  module outer_cut(box_side, box_border, box_height, cut_radius) {
    // color("white", 0.5)
    translate([0, 0, box_height - cut_height + 0.01])
      linear_extrude(cut_height)
        difference() {
          circle(cut_radius + 4 * box_border, $fn=128);
          circle(cut_radius, $fn=128);
        }
  }

  // corte interno da tampa
  module inner_cut(box_side, box_border, box_height, cut_radius) {
    // color("white", 0.5)
    translate([0, 0, box_border])
      linear_extrude(box_height)
        circle(cut_radius + cover_clearance, $fn=120);
  }

  module trimo_chamfer(side, corner_radius, chamfer) {
    linear_extrude(height=chamfer, scale=1 + (chamfer * 1.55) / side)
      offset(delta=chamfer, $fn=120)
        triangle_scaled_rounded(side - chamfer * 3, corner_radius - chamfer * 1.2);
  }

  module poligon_torus(clearance) {
    rotate_extrude($fn=120)
      translate([cut_radius - 0.025, 0])
        polygon(
          [
            [0, -locker_height * 1.5 - clearance],
            [locker_height + clearance, -locker_height / 3],
            [locker_height + clearance, locker_height / 3],
            [0, locker_height * 1.5 + clearance],
          ]
        );
  }

  module locker(locker_offset, clearance = 0) {
    // locker_offset: distância do chao da caixa até o centro do encaixe
    // color("white", 0.5)
    intersection() {
      translate([0, 0, locker_offset])
        poligon_torus(clearance);
      trimo(box_side + box_border + 0.01, corner_radius, box_height);
    }
  }

  if (set == 6) {
    // cover
    //color("yellow", 0.5)
    translate([0, 0, chamfer_size - 0.01])
      difference() {
        trimo(box_side + box_border, corner_radius, cut_height + box_border - chamfer_size);
        translate([0, 0, box_border - chamfer_size + 0.01]) // fundo da caixa
          box_inside(cut_height - chamfer_size);
        inner_cut(box_side, box_border - chamfer_size, cut_height, cut_radius);
        locker(locker_offset=cut_height / 2 + box_border - chamfer_size, clearance=cover_clearance);
      }
    trimo_chamfer(box_side, corner_radius, chamfer_size);
  }

  if (set == 5) {
    // box
    translate([0, 0, chamfer_size - 0.01])
      difference() {
        trimo(box_side + box_border, corner_radius, box_height - chamfer_size);
        translate([0, 0, box_border - chamfer_size]) // fundo da caixa
          box_inside(box_height - chamfer_size);
        outer_cut(box_side, box_border, box_height - chamfer_size, cut_radius); // encaixe da tampa
      }
    trimo_chamfer(box_side, corner_radius, chamfer_size);
    locker(locker_offset=box_height - cut_height / 2);
  }
}

if (set == 5) {
  box(set);
} else if (set == 6) {
  box(set);
} else {
  set_of_trimos(all_sets[set]);
}
