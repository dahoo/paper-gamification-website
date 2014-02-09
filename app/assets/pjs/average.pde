var avg_len = 0;
var identifier = "avg_len";
var col = color(0, 100, 100);
var minval = 2;
var maxval = 7;

void setup(){
	size(300, 200);
	noLoop();	
	background(0);
	colorMode(HSB,360,100,100,100);
	strokeCap(SQUARE);
}

void update(stats){
	avg_len = stats[identifier];
	
	// RESET
	background(0);

	// SETUP
	col = color(map(avg_len, minval, maxval, 0, 100), 100, 100);
	setup_label();
	setup_frame();
	setup_scale();
}

void setup_label(){
	textFont(createFont("Arial",70,true));
	fill(360,0,100); // White
	textAlign(CENTER);

	text(nf(avg_len, 0, 2), width/2, 100);
}

void setup_frame(){
	var inset = 40;
	var yOff = 30;
	var h = 90;

	noFill();
	strokeWeight(1);
	stroke(col);

	rect(inset, yOff, width-2*inset, h);
}

void setup_scale(){
	var yOff = 140;
	var inset = 10;
	var stripes = 6;
	var stripeHeight = 10;
	var line_width = width - 2 * inset;
	var increment = line_width / float(stripes-1);

	stroke(360,0,100); // White
	strokeWeight(2);
	line(inset, yOff, width - inset, yOff);
	for (float x = inset; x <= width - inset; x += increment){
		// Stripe
		stroke(360,0,100, 80);
		strokeWeight(3);
		line(x, yOff - stripeHeight/2.0, x, yOff + stripeHeight/2.0);

		// Stripe-text
		float percentage = float(x-inset) / float(line_width);
		var label = nf((percentage * (maxval - minval) + minval), 0, 1);
		textFont(createFont("Arial", 12, true));
		text(label, x, yOff + 20);
	}

	// Mark current number as special stripe
	float x = map(avg_len, minval, maxval, inset, width-inset);
	fill(col);
	stroke(col);

	strokeWeight(0);
	ellipse(x,yOff,10,10);
	strokeWeight(4);
	line(x, yOff - stripeHeight*2, x, yOff+5);
}