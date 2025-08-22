tile_size = 19;
tile_thickness = 6.4;
corner_radius = 1.5;

// intended for multimaterial 3d printing so use a tiny depth to create a face
// that can be painted with the fill tool, but will still be printed on the
// first layer
text_depth = 0.001;

score_txt_size = 3.5;
letter_txt_size = 9;
letter_font = "DejaVu Sans:style=Bold";
score_font = "URW Gothic:style=Demi";

// when `all` is not true, only generates this tile
letter = "[blank]";

// when true, generates all tiles with their distribution on a grid
all = false;


module letter(letter) {
  color("black")
    translate([-0.5,1,tile_thickness - text_depth])
    linear_extrude(text_depth)
    text(letter, halign="center", valign="center", size=letter_txt_size, font=letter_font);
}

module score(n) {
  color("black")
    translate([(tile_size/2)-1.5, -(tile_size/2)+1.5, tile_thickness - text_depth])
    linear_extrude(text_depth)
    text(str(n), halign="right", valign="bottom", size=score_txt_size, font=score_font);
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
      fillet(r=-corner_radius) {
        square(tile_size, center=true);
      }
    cylinder(h=4.5, r=7.5, $fn=30);
  }
}

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
  if(letter == undef || letter == "[blank]") blank();
  else letter_tile(letter, score);
}

module build(dict) {
  if (all || (letter == undef && $preview)) {
    // generate a vector with each tile's letter and score
    defs = [
      for(k = [ 0 : len(dict) - 1 ]) 
        for ( i = [ 1 : dict[k][2] ] ) 
          [dict[k][0], dict[k][1]]
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
    if (letter == undef || letter == "[blank]") {
      blank();
    } else {
      index = search(letter, dict);
      echo(index);
      tile=dict[index[0]];
      letter_tile(tile[0], tile[1]);
    }
  }
}
