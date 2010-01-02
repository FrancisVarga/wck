﻿package Box2DAS.Dynamics.Contacts {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2ContactID extends b2Base {
	
		public function b2ContactID(p:int) {
			_ptr = p;
		}
	
		public function get key():int { return mem._mr32(_ptr + 0); }
		public function set key(v:int):void { mem._mw32(_ptr + 0, v); }

	}
}