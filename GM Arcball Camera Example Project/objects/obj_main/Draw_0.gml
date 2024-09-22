#region Example Scene

// Apply Camera
cam.apply();

//Clear Frame
draw_clear_alpha(0,0);

// Draw Circles
draw_circle_color(0, 0, 10, c_white, c_white, false);
draw_circle_color(-20, -20, 10, c_red, c_red, false);
draw_circle_color(20, 20, 10, c_blue, c_blue, false);
draw_circle_color(20, -20, 10, c_yellow, c_yellow, false);
draw_circle_color(-20, 20, 10, c_green, c_green, false);

#endregion