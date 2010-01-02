﻿package wck {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * Implements the b2World callback functions as native AS3 events.
	 */
	public class EventWorld extends b2World {
		
		/// Time in milliseconds that the last time step was started at. This can be used to check
		/// if buffered / cached world data is outdated.
		public var stepTime:int = 0;
		
		public function EventWorld(g:V2, s:Boolean = true) {
			super(g, s);
		}
		
		public override function Step(timeStep:Number, velocityIterations:int, positionIterations:int):void {
			stepTime = getTimer();
			super.Step(timeStep, velocityIterations, positionIterations);
		}
		
		public override function BeginContact(c:int, a:b2Fixture, b:b2Fixture):void {
			ContactDispatch(ContactEvent.BEGIN_CONTACT, c, a, b);
		}
		
		public override function EndContact(c:int, a:b2Fixture, b:b2Fixture):void {
			ContactDispatch(ContactEvent.END_CONTACT, c, a, b);
		}
		
		public override function PreSolve(c:int, a:b2Fixture, b:b2Fixture):void {
			ContactDispatch(ContactEvent.PRE_SOLVE, c, a, b);
		}
		
		public override function PostSolve(c:int, a:b2Fixture, b:b2Fixture):void {
			ContactDispatch(ContactEvent.POST_SOLVE, c, a, b);
		}
		
		public override function ContactDispatch(t:String, c:int, a:b2Fixture, b:b2Fixture):void {
			var ed:IEventDispatcher = a.m_userData as IEventDispatcher;
			if(ed) {
				ed.dispatchEvent(new ContactEvent(t, c, this, a, b, 1));
			}
			ed = b.m_userData as IEventDispatcher;
			if(ed) {
				ed.dispatchEvent(new ContactEvent(t, c, this, a, b, -1));
			}
		}
		
		public override function SayGoodbyeJoint(j:b2Joint):void {
			var ed:IEventDispatcher = j.m_userData as IEventDispatcher;
			if(ed) {
				ed.dispatchEvent(new GoodbyeJointEvent(j));
			}
		}
		
		public override function SayGoodbyeFixture(f:b2Fixture):void {
			var ed:IEventDispatcher = f.m_userData as IEventDispatcher;
			if(ed) {
				ed.dispatchEvent(new GoodbyeFixtureEvent(f));
			}
		}
	}
}