// Creates a struct containing all the stuff you need for a dope camera system
// System is intended to mostly replicate the Blender viewport camera
// Created by Derik.NET
function arcball_camera() constructor {
	
	// Initialize
	dynamic = camera_create();
	
	// Settings
	controls_enabled = true;
	zoom = 50.0;
	mouse_pos				= [0, 0];
	mouse_pos_prev	= [0, 0];
	directional_pan_scale	= 0.0015;
	oribtal_pan_scale			= 0.003;
	zoom_strength				= 0.01;

	// Vectors
	target_pos			= [0, 0, 0];
	view_pos				= [0, 0, 0];
	up							= [0, 0, 1];
	dir							= [0, 1, 0];
	right						= [1, 0, 0];
	world_right			= [1, 0, 0];
	world_forward	= [0, 1, 0];
	world_up				= [0, 0, 1];
	
	// Defaults
	default_view_pos		= variable_clone(view_pos);
	default_target_pos	= variable_clone(target_pos);
	default_up					= variable_clone(up);
	default_dir					= variable_clone(dir);

	// Quaternions
	view_quat = [0, 0, 0, 1];
	
	// Matrices
	view_mat = undefined;
	proj_mat = undefined; 

	#region Vector and Quaternion 
		
	// Add 
	static add = function(_array_0, _array_1) {
		gml_pragma("forceinline");
		return [_array_0[0] + _array_1[0], _array_0[1] + _array_1[1], _array_0[2] + _array_1[2]];
	}

	// Subtract 
	static sub = function(_array_0, _array_1) {
		gml_pragma("forceinline");
		return [_array_0[0] - _array_1[0], _array_0[1] - _array_1[1], _array_0[2] - _array_1[2]];
	}
	
	// Multiply
	static mul = function(_array_0, _array_1) {
		gml_pragma("forceinline");
		var array_len = array_length(_array_0);
		var res;
		switch(array_len) {
			
			// Vector
			case 3: 
				res = [_array_0[0] * _array_1[0], _array_0[1] * _array_1[1], _array_0[2] * _array_1[2]];
			break;
			
			// Quaternion
			case 4:
				var qx	=	_array_0[0]	*	_array_1[3]	+	_array_0[1]	*	_array_1[2]	-	_array_0[2]	*	_array_1[1]	+	_array_0[3]	*	_array_1[0];
				var qy	=	-_array_0[0]	*	_array_1[2]	+	_array_0[1]	*	_array_1[3]	+	_array_0[2]	*	_array_1[0]	+	_array_0[3]	*	_array_1[1];
				var qz	=	_array_0[0]	*	_array_1[1]	-	_array_0[1]	*	_array_1[0]	+	_array_0[2]	*	_array_1[3]	+	_array_0[3]	*	_array_1[2];
				var qw	=	-_array_0[0]	*	_array_1[0]	-	_array_0[1]	*	_array_1[1]	-	_array_0[2]	*	_array_1[2]	+	_array_0[3]	*	_array_1[3];
				res = [qx, qy, qz, qw];
			break;
			
		}
		return res;
	}
	
	// Magnitude
	static magnitude = function(_array) {
		gml_pragma("forceinline");
		var array_len = array_length(_array);
		var res;
		switch(array_len) {
			
			// Vector
			case 3: 
				res = sqrt(_array[0] * _array[0] + _array[1] * _array[1] + _array[2] * _array[2]);
			break;
			
			// Quaternion
			case 4:
				res = sqrt(_array[0] * _array[0] + _array[1] * _array[1] + _array[2] * _array[2] + _array[3] * _array[3]); 
			break;
			
		}
		return res;
	}
	
	// Normalize
	static normalize = function(_array) {
		gml_pragma("forceinline");
		var array_len = array_length(_array);
		var res, mag, len;
		switch(array_len) {
			
			// Vector
			case 3: 
				mag = self.magnitude(_array);
				len =  1.0 / mag;
				if mag = 0 or len = 0 or is_nan(mag) or is_nan(len) {
					res = [0, 0, 0];
				} else {
					res = [_array[0] * len, _array[1] * len, _array[2] * len];	
				}
			break;
			
			// Quaternion
			case 4:
				mag = self.magnitude(_array);
				len = 1.0 / mag;
				if mag = 0 or len = 0 or is_nan(mag) or is_nan(len) {
					res = [0, 0, 0, 1];
				} else {
					res = [_array[0] * len, _array[1] * len, _array[2] * len, _array[3] * len];
				}
			break;
			
		}
		return res;
	}
	
	// Negate
	static negate = function(_array) {
		gml_pragma("forceinline");
		var array_len = array_length(_array);
		var res;
		switch(array_len) {
			
			// Vector
			case 3: 
				res = [-_array[0], -_array[1], -_array[2]]
			break;
			
			// Quaternion
			case 4:
				res = [-_array[0], -_array[1], -_array[2], -_array[3]]
			break;
			
		}
		return res;
	}
	
	// Cross
	static cross = function(_array_0, _array_1) {
		gml_pragma("forceinline");
		return [_array_0[1]*_array_1[2] - _array_0[2]*_array_1[1], _array_0[2]*_array_1[0] - _array_0[0]*_array_1[2], _array_0[0]*_array_1[1] - _array_0[1]*_array_1[0]];
	}
	
	// Rotates a Vector using a Quaternion
	static rotate_vec_by_quat = function(_vec, _quat) {
		var _x = _quat[0] * 2.0;
		var _y = _quat[1] * 2.0;
		var _z = _quat[2] * 2.0;
		var xx = _quat[0] * _x;
		var yy = _quat[1] * _y;
		var zz = _quat[2] * _z;
		var xy = _quat[0] * _y;
		var xz = _quat[0] * _z;
		var yz = _quat[1] * _z;
		var wx = _quat[3] * _x;
		var wy = _quat[3] * _y;
		var wz = _quat[3] * _z;
		var res = [0, 0, 0];
		res[0] = (1.0 - (yy + zz)) * _vec[0] + (xy - wz) * _vec[1] + (xz + wy) * _vec[2];
		res[1] = (xy + wz) * _vec[0] + (1.0 - (xx + zz)) *_vec[1] + (yz - wx) * _vec[2];
		res[2] = (xz - wy) * _vec[0] + (yz + wx) * _vec[1] + (1.0 - (xx + yy)) * _vec[2];
		return res;
	}
	
	// Generates a Quaternion based on the Dir and Up vectors
	static from_look_rotation = function(_dir, _up) {
		gml_pragma("forceinline");
		
		// Updates Vectors
		dir		= normalize(negate(_dir));
		right	= normalize(cross(_up, dir));
        up		= normalize(cross(dir, right));
		var res;
	
		// IIRC this was originally based on Unity's FromLookRotation function
		// with some slight modifications for GameMaker
        var num8 = (right[0] + up[1]) + dir[2];
        if num8 > 0 {
            var num = sqrt(num8 + 1);
            num = 0.5 / num;
            res = [(up[2] - dir[1]) * num, (dir[0] - right[2]) * num, (right[1] - up[0]) * num, num * 0.5];
        } else if right[0] >= up[1] and right[0] >= dir[2] {
            var num7 = sqrt(((1 + right[0]) - up[1]) - dir[2]);
            var num4 = 0.5 / num7;
            res =[0.5 * num7, (right[1] + up[0]) * num4, (right[2] + dir[0]) * num4, (up[2] - dir[1]) * num4];
        } else if (up[1] > dir[2]) {
            var num6 = sqrt(((1 + up[1]) - right[0]) - dir[2]);
            var num3 = 0.5 / num6;
            res = [(up[0] + right[1]) * num3, 0.5 * num6, (dir[1] + up[2]) * num3, (dir[0] - right[2]) * num3];
        } else {
			var num5 = sqrt(((1 + dir[2]) - right[0]) - up[1]);
	        var num2 = 0.5 / num5;
	        res = [(dir[0] + right[2]) * num2, (dir[1] + up[2]) * num2, 0.5 * num5, (right[1] - up[0]) * num2];
		}
		return res;
	}

	// Returns a Quateranion representing a Rotation around a Unit Axis by an Angle in Radians
	static from_angle_axis = function(_angle, _axis) {
		gml_pragma("forceinline");
        var sina		= sin(0.5 * _angle);
		var cosa	= cos(0.5 * _angle);
		return [_axis[0] * sina, _axis[1] * sina, _axis[2] * sina, cosa];
	}
	
	//Returns the quaternion, position, and scale as a view matrix
	static quat_as_view_matrix = function(_quat, _pos) {
	    gml_pragma("forceinline");
	
		var mat = array_create(16, 0);
		var sq = [_quat[0] * _quat[0], _quat[1] * _quat[1], _quat[2] * _quat[2], _quat[3] * _quat[3]];
		
		// Rotation
		mat[0]		= sq[0] - sq[1] - sq[2] + sq[3];
		mat[5]		= -sq[0] + sq[1] - sq[2] + sq[3];
		mat[10]		= -sq[0] - sq[1] + sq[2] + sq[3];

		var tmp1 = _quat[0] * _quat[1];
		var tmp2 = _quat[2] * _quat[3];
		mat[1] = 2.0 * (tmp1 + tmp2);
		mat[4] = 2.0 * (tmp1 - tmp2);

		tmp1 = _quat[0] * _quat[2];
		tmp2 = _quat[1] * _quat[3];
		mat[2] = 2.0 * (tmp1 - tmp2);
		mat[8] = 2.0 * (tmp1 + tmp2);

		tmp1 = _quat[1] * _quat[2];
		tmp2 = _quat[0] * _quat[3];
		mat[6] = 2.0 * (tmp1 + tmp2);
		mat[9] = 2.0 * (tmp1 - tmp2);

		// Invert Rotation
		for (var i = 0; i < 3; i++) {
			for (var j = i + 1; j < 3; j++) {
			    var temp = mat[i * 4 + j];
			    mat[i * 4 + j] = mat[j * 4 + i];
			    mat[j * 4 + i] = temp;
			}
		}

		// Translation
		mat[12] = -(mat[0] * _pos[0] + mat[4] * _pos[1] + mat[8] * _pos[2]);
		mat[13] = -(mat[1] * _pos[0] + mat[5] * _pos[1] + mat[9] * _pos[2]);
		mat[14] = -(mat[2] * _pos[0] + mat[6] * _pos[1] + mat[10] * _pos[2]);
		mat[15] = 1.0;
		return mat;
	
	}
	
	#endregion
	#region Utility
	
	// Set Projection Matrix
	static set_projection = function(_mat) {
		proj_mat = _mat;
	}
	
	// Reset 
	static reset = function() {
		view_pos			= variable_clone(default_view_pos);
		target_pos		= variable_clone(default_target_pos);
		up						= variable_clone(default_up);
		dir						= variable_clone(default_dir);
		view_quat			= from_look_rotation(dir, up);
		var xrot_quat	= normalize(from_angle_axis(0, world_up));
		var yrot_quat	= normalize(from_angle_axis(0, world_right));
		view_quat			= normalize(mul(xrot_quat, view_quat));
		view_quat			= normalize(mul(view_quat, yrot_quat));
	}
	
	// Control
	static control = function() {
		
		// Get Input
		mouse_pos	= [mouse_x, mouse_y];
		var mouse_delta = [mouse_pos[0] - mouse_pos_prev[0], mouse_pos[1] - mouse_pos_prev[1]];
		var mouse_scroll = -mouse_wheel_up()+mouse_wheel_down();
		var numpad = [	keyboard_check_pressed(vk_numpad0),
										keyboard_check_pressed(vk_numpad1), keyboard_check_pressed(vk_numpad2), keyboard_check_pressed(vk_numpad3), 
										keyboard_check_pressed(vk_numpad4), keyboard_check_pressed(vk_numpad5), keyboard_check_pressed(vk_numpad6), 
										keyboard_check_pressed(vk_numpad7), keyboard_check_pressed(vk_numpad8), keyboard_check_pressed(vk_numpad9)];
		var plusminus = -keyboard_check(vk_add)+keyboard_check(vk_subtract);
		var shift = keyboard_check(vk_shift);
		var mouse_middle = mouse_check_button(mb_middle)
		
		// Middle Mouse Actions
		if mouse_middle {
			
			// Directional Pan
			if shift { 
		 
				//Pan Movement
				var pan = [mouse_delta[0]  * zoom * directional_pan_scale, mouse_delta[1]  * zoom * directional_pan_scale];
				
				// Adjust to Camera Axis
				pan = add(mul(right, [pan[0], pan[0], pan[0]]), mul(up, [pan[1], pan[1], pan[1]]));
				
				// Move
				target_pos = add(target_pos, pan);
		 
			} else { 	//Orbital Pan
		
				var xrot_quat = normalize(from_angle_axis(-mouse_delta[0] * oribtal_pan_scale, world_up));
				var yrot_quat = normalize(from_angle_axis(mouse_delta[1]  * oribtal_pan_scale, world_right));
				view_quat		= normalize(mul(xrot_quat, view_quat));
				view_quat		= normalize(mul(view_quat, yrot_quat));
				dir					= normalize(rotate_vec_by_quat(world_up, view_quat));
				right				= normalize(rotate_vec_by_quat(world_right, view_quat));
		
			}
			
		}
		
		// Scroll
		if mouse_scroll != 0 {
	
			//Zoom
			zoom *= power(zoom, mouse_scroll * zoom_strength);
	
		}

		// Update Mouse Previous 
		mouse_pos_prev = variable_clone(mouse_pos);
		
		//Scroll Wheel Actions
		if mouse_scroll != 0 {
	
			//Zoom
			zoom *= power(zoom, mouse_scroll*zoom_strength);
	
		}

		//Align Camera to World -Z Shortcut
		if numpad[7] {
			dir					= normalize(negate(world_up));
			view_quat		= normalize(from_look_rotation(world_up, world_right));
			right				= normalize(world_right);

		}
			
		//Align Camera to World X Shortcut
		if numpad[3] {
			dir					= normalize(negate(world_right));
			view_quat		= normalize(from_look_rotation(negate(world_right), world_up));
			right				= normalize(world_forward);
		}
			
		//Align Camera to World -Y Shortcut
		if numpad[1] {
			dir					= normalize(world_forward);
			view_quat		= normalize(from_look_rotation(world_forward, world_up));
			right				= normalize(world_right);
		}
			
		//Align Camera to World -X Shortcut
		if numpad[9] {
			dir					= normalize(world_right);
			view_quat		= normalize(from_look_rotation(world_right, world_up));
			right				= normalize(world_forward);
		}
			
		//Rotate Camera around View Up
		var numpad_uprot = numpad[6] - numpad[4];
		if numpad_uprot != 0 {
			var xrot_quat	= normalize(from_angle_axis(numpad_uprot * degtorad(90/3), world_up));
			view_quat			= normalize(mul(xrot_quat, view_quat));
			dir						= normalize(rotate_vec_by_quat(world_up, view_quat));
			right					= normalize(rotate_vec_by_quat(world_right, view_quat));
		}

		//Rotate Camera around View Right
		var numpad_rightrot = numpad[8] - numpad[2];
		if numpad_rightrot != 0 {
			var yrot_quat	= normalize(from_angle_axis(numpad_rightrot * degtorad(90/3), world_right));
			view_quat			= normalize(mul(view_quat, yrot_quat));
			dir						= normalize(rotate_vec_by_quat(world_up, view_quat));
			right					= normalize(rotate_vec_by_quat(world_right, view_quat));
		}

	}
	
	// Update
	static update = function() {
		if controls_enabled {control();}
		dir = normalize(rotate_vec_by_quat(world_up, view_quat));
		right = normalize(rotate_vec_by_quat(world_right, view_quat));
		zoom = max(zoom, 0.1);
		zoom_strength = max(zoom_strength, 0.001);
		view_pos	= add(target_pos, mul(dir, [-zoom, -zoom, -zoom]));
		up				= normalize(cross(dir, right));
		view_quat	= normalize(view_quat);
		view_mat	= quat_as_view_matrix(view_quat, view_pos);
	}
	
	// Apply 
	static apply = function() {
		camera_set_view_mat(dynamic, view_mat);
		camera_set_proj_mat(dynamic, proj_mat);
		camera_apply(dynamic);
	}
	
	#endregion

}