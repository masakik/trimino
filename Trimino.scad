// Tri-Mos6 generator
// Copyright 2023 Chris Cogdon
// License: Creative Commons CC-BY-SA-4.0
// ...

selected_index = 0; // [0:Base 1-5, 1:Base with 0, 2:Set with 6, 3:Reverse set, 4:Teste]

trimo_height = 8;
trimo_side = 40;
trimo_corner_radius = 2;

trimo_text_font = "Ariel";
trimo_text_size = 8;
trimo_text_relief = 0.5;
trimo_text_offset_factor = -0.4;

trimo_padding_x = -16; // bem pertos
trimo_padding_y = 0;

trimo_printing_x = 9; // 9 por linha, cabe na Bambu A1
trimo_printing_y = 6; // Número de linhas

// Oh, how I wish OpenSCAD had Python's generators.
trimos_base_1_5 = [
  [5, 5, 5],
  [5, 5, 4],
  [5, 5, 3],
  [5, 5, 2],
  [5, 5, 1],
  [5, 4, 4],
  [5, 4, 3],
  [5, 4, 2],
  [5, 4, 1],
  [5, 3, 3],
  [5, 3, 2],
  [5, 3, 1],
  [5, 2, 2],
  [5, 2, 1],
  [5, 1, 1],
  [4, 4, 4],
  [4, 4, 3],
  [4, 4, 2],
  [4, 4, 1],
  [4, 3, 3],
  [4, 3, 2],
  [4, 3, 1],
  [4, 2, 2],
  [4, 2, 1],
  [4, 1, 1],
  [3, 3, 3],
  [3, 3, 2],
  [3, 3, 1],
  [3, 2, 2],
  [3, 2, 1],
  [3, 1, 1],
  [2, 2, 2],
  [2, 2, 1],
  [2, 1, 1],
  [1, 1, 1],
];

trimos_base_with_0 = [
  [5, 5, 0],
  [5, 4, 0],
  [5, 3, 0],
  [5, 2, 0],
  [5, 1, 0],
  [5, 0, 0],
  [4, 4, 0],
  [4, 3, 0],
  [4, 2, 0],
  [4, 1, 0],
  [4, 0, 0],
  [3, 3, 0],
  [3, 2, 0],
  [3, 1, 0],
  [3, 0, 0],
  [2, 2, 0],
  [2, 1, 0],
  [2, 0, 0],
  [1, 1, 0],
  [1, 0, 0],
  [0, 0, 0],
];

trimos_set_with_6 = [
  [6, 6, 6],
  [6, 6, 5],
  [6, 6, 4],
  [6, 6, 3],
  [6, 6, 2],
  [6, 6, 1],
  [6, 6, 0],
  [6, 0, 0],
  [6, 5, 5],
  [6, 5, 4],
  [6, 5, 3],
  [6, 5, 2],
  [6, 5, 1],
  [6, 5, 0],
  [6, 4, 4],
  [6, 4, 3],
  [6, 4, 2],
  [6, 4, 1],
  [6, 4, 0],
  [6, 3, 3],
  [6, 3, 2],
  [6, 3, 1],
  [6, 3, 0],
  [6, 2, 2],
  [6, 2, 1],
  [6, 2, 0],
  [6, 1, 1],
  [6, 1, 0],
];

trimos_set_reverse = [
  [6, 4, 5],
  [6, 3, 5],
  [6, 3, 4],
  [6, 2, 5],
  [6, 2, 4],
  [6, 2, 3],
  [6, 1, 5],
  [6, 1, 4],
  [6, 1, 3],
  [6, 1, 2],
  [6, 0, 5],
  [6, 0, 4],
  [6, 0, 3],
  [6, 0, 2],
  [6, 0, 1],
  [5, 3, 4],
  [5, 2, 4],
  [5, 2, 3],
  [5, 1, 4],
  [5, 1, 3],
  [5, 1, 2],
  [5, 0, 4],
  [5, 0, 3],
  [5, 0, 2],
  [5, 0, 1],
  [4, 2, 3],
  [4, 1, 3],
  [4, 0, 3],
  [4, 0, 2],
  [4, 0, 1],
  [3, 1, 2],
  [3, 0, 2],
  [3, 0, 1],
  [2, 0, 1],
];

trimos_teste = [
  [1, 2, 3],
];

all_sets = [
  trimos_base_1_5,
  trimos_base_with_0,
  trimos_set_with_6,
  trimos_set_reverse,
  trimos_teste,
];

module centered_equilateral_triangle() {
  polygon(
    [
      [-0.5, -0.5 * tan(30)],
      [.5, -0.5 * tan(30)],
      [0, 0.5 * (tan(60) - tan(30))],
    ]
  );
}

module triangle_scaled() {
  scale(trimo_side)
    centered_equilateral_triangle();
}

module rounded_triangle() {
  offset(r=trimo_corner_radius, $fn=40)
    offset(delta=-trimo_corner_radius)
      triangle_scaled();
}

module base_trimo() {
  linear_extrude(trimo_height)
    rounded_triangle();
}

module base_trimo_with_center(center_diameter = 4) {
  //  ressalto central esférico 
  union() {
    base_trimo();
    translate([0, 0, trimo_height - center_diameter / 2 + trimo_text_relief])
      sphere(r=center_diameter / 2, $fn=40);
  }

  // rebaixo central cilindrico
  //   difference() {
  //     base_trimo();
  //     translate([0, 0, trimo_height - 2])
  //       cylinder(h=trimo_height, r=center_diameter / 2, $fn=32);
  //   }
}

module numbered_trimo(numbers) {
  base_trimo_with_center();
  translate([0, 0, trimo_height]) {
    for (i = [0:2]) {
      rotate([0, 0, 120 * i - 60])
        translate([0, trimo_side * trimo_text_offset_factor, 0])
          linear_extrude(trimo_text_relief)
            text(str(numbers[i]), font=trimo_text_font, size=trimo_text_size, halign="center");
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

set_of_trimos(all_sets[selected_index]);
