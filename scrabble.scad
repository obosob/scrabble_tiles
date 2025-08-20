tile_size = 19;
tile_thickness = 6.4;
corner_radius = -1.5;
text_depth = 0.001;
score_txt_size=3.5;
letter_txt_size=9;
font="DejaVu Sans:style=Bold";

module letter(letter) {
  color("black")
    translate([0,1,tile_thickness - text_depth])
    linear_extrude(text_depth)
    text(letter, halign="center", valign="center", size=letter_txt_size, font=font);
}

module score(n) {
  color("black")
    translate([(tile_size/2)-1.5, -(tile_size/2)+1.5, tile_thickness - text_depth])
    linear_extrude(text_depth)
    text(n, halign="right", valign="bottom", size=score_txt_size, font=font);
}

module fillet(r) {
  offset(r = -r, $fn=30) {
    offset(delta = r) {
      children();
    }
  }
}

module blank() {
  difference() {
    linear_extrude(tile_thickness)
      fillet(r=corner_radius) {
        square(tile_size, center=true);
      }
    cylinder(h=4.5, r=7.5, $fn=30);
  }
}

letter = undef;
all = false;

// 2 blank tiles (scoring 0 points)
// 1 point: A ×19, N ×9, E ×8, I ×8, T ×5, U ×5, R ×4, O ×3, S ×3
// 2 points: K ×3, M ×3
// 3 points: D ×4, G ×3
// 4 points: L ×3, H ×2, P ×2
// 5 points: B ×4, Y ×2, F ×1, V ×1
// 8 points: C ×3, W ×1
// 10 points: J ×1, Z ×1
letters = [
  [undef, undef, 2],
  ["A", "1", 19],
  ["N", "1", 9],
  ["E", "1", 8],
  ["I", "1", 8],
  ["T", "1", 5],
  ["U", "1", 5],
  ["R", "1", 4],
  ["O", "1", 3],
  ["S", "1", 3],
  ["K", "2", 3],
  ["M", "2", 3],
  ["D", "3", 4],
  ["G", "3", 3],
  ["L", "4", 3],
  ["H", "4", 2],
  ["P", "4", 2],
  ["B", "5", 4],
  ["Y", "5", 2],
  ["F", "5", 1],
  ["V", "5", 1],
  ["C", "8", 3],
  ["W", "8", 1],
  ["J", "10", 1],
  ["Z", "10", 1]
  ];

  module letter_tile(letter, score) {
    difference() 
    {
      blank();
      letter(letter);
      score(score);
    };
  }

module grid() {
  echo($children);
  x = round(sqrt($children));
  for( i = [ 0 : $children - 1 ] ) {
    echo(i);
    translate([i % x, floor(i / x), 0])
      children(i);
  }
}

module tile(letter, score) {
  if(letter == undef) blank();
  else letter_tile(letter, score);
}

if (all || (letter == undef && $preview)) {
  // generate a vector with each tile's letter and score
  defs = [
    for(k = [ 0 : len(letters) - 1 ]) 
      for ( i = [ 1 : letters[k][2] ] ) 
        [letters[k][0], letters[k][1]]
  ];
  x = round(sqrt(len(defs)));
  // lay them out in a grid
  for( i = [ 0 : len(defs) - 1 ] ) {
    translate([
        i % x * (tile_size + 1), 
        floor(i / x) * (tile_size + 1),
        0]) 
      tile(defs[i][0], defs[i][1]);
  }
} else {
  if (letter == undef) {
    blank();
  } else {
    index = search(letter, letters);
    tile=letters[index[0]];
    letter_tile(tile[0], tile[1]);
  }
}
