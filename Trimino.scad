// Tri-Mos6 generator
// Copyright 2023 Chris Cogdon
// License: Creative Commons CC-BY-SA-4.0
// ...

selected_index = 0; // [0:Base 1-5, 1:Base with 0, 2:Set with 6, 3:Reverse set, 4:Teste, 5:Caixa]

trimo_side = 45;
trimo_height = 8;
trimo_corner_radius = 5;

/* [Numbers] */
number_enabled = true; // liga/desliga
trimo_text_font = "Ariel";
trimo_text_size = 8;
trimo_text_relief = 0.5;
trimo_text_offset_factor = -0.4;
text_color = "red";

/* [Center] */
center_enabled = true; // liga/desliga
center_diameter = 5; //[1:8]
center_mode = "spherical_boss"; // [none:Nenhum, spherical_boss:Spherical Boss, spherical_cavity:Sphere cavity, cavity:Rebaixo cilíndrico]

/* [Paddings] */
trimo_padding_x = 2; // bem pertos
trimo_padding_y = 2;

/* [Rows and columns] */
trimo_printing_x = 9; // 9 por linha, cabe na Bambu A1
trimo_printing_y = 6; // Número de linhas

include <pecas.scad>;

all_sets = [
  trimos_base_1_5,
  trimos_base_with_0,
  trimos_set_with_6,
  trimos_set_reverse,
  trimos_teste,
  caixa,
];

//caixa: side 235, raduis 29

module trimo(side, corner_radius, height) {

  // triângulo equilátero centrado
  module centered_equilateral_triangle() {
    polygon(
      [
        [-0.5, -0.5 * tan(30)],
        [0.5, -0.5 * tan(30)],
        [0, 0.5 * (tan(60) - tan(30))],
      ]
    );
  }

  // escala baseada em trimo_side
  module triangle_scaled() {
    scale(side)
      centered_equilateral_triangle();
  }

  // cantos arredondados usando offset
  module triangle_scaled_rounded() {
    offset(r=corner_radius, $fn=80)
      offset(delta=-corner_radius)
        triangle_scaled();
  }

  // extrusão final
  linear_extrude(height)
    triangle_scaled_rounded();
}

module base_trimo_with_center() {
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

module numbered_trimo(numbers) {
  base_trimo_with_center();
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
            numbered_trimo(trimos[trimo_index]);
      }
    }
  }
}

module trimos_inline_x(n, flip = 0) {
  base_x = -(n - 1) * trimo_side * 0.25;
  base_y = -1.333 * trimo_side * 0.86625;
  color(text_color);
  for (i = [0:n - 1]) {
    tx = i * trimo_side * 0.5 + base_x;
    ty = ((i + flip) % 2) * 0.2886 * trimo_side + base_y;
    translate([tx, ty, 0])
      rotate([0, 0, 180 * ( (i + flip) % 2)]) // alterna 0° / 180°
        translate([0, 0, -0.01]) // evita z-fighting
          trimo(trimo_side, 0, 10);
  }
}

module caixa() {
  side = 5 * trimo_side * 1.02;
  corner_radius = 0.577 * trimo_side * 1.02;
  height = 9;
  border = 5;
  difference() {
    trimo(side + border, corner_radius, height);
    trimos_inline_x(7, 1);
  }
}

if (selected_index == 5) {
  caixa();
} else {
  set_of_trimos(all_sets[selected_index]);
}
