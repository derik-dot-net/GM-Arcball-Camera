#region Setup

//Enable 3D
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

// Create Camera
cam = new arcball_camera();

// Define & Set Projection
proj_mat = matrix_build_projection_perspective_fov(-60, window_get_width()/window_get_height(), 0.01, 10000.0)
cam.set_projection(proj_mat);

#endregion
