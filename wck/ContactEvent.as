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
	
	/**
	 * A native flash event class for handling Box2d contact events. If a fixture's user data implements
	 * IEventDispatcher (for example, if m_userData is a MovieClip), that event dispatcher will be used
	 * to broadcast contact events involving the fixture. 
	 *
	 * GOTCHA: A fixture will only dispatch contact events if reportBeginContact, reportEndContact, etc. are set to true.
	 */
	public class ContactEvent extends Event {
		
		/// The various event types.		
		public static var BEGIN_CONTACT:String = 'onBeginContact';
		public static var END_CONTACT:String = 'onEndContact';
		public static var PRE_SOLVE:String = 'onPreSolve';
		public static var POST_SOLVE:String = 'onPostSolve';
		
		/// The world the event occurred in.
		public var world:EventWorld;
		
		/// The b2Contact. 
		public var contact:b2Contact;
		
		/// The "target" b2Fixture. This fixture's userData is dispatching the event (fixture.m_userData = this.target).
		public var fixture:b2Fixture;
		
		/// The other b2Fixture involved in the collision.
		public var other:b2Fixture;
		
		/// the "target" property is the BodyShape dispatching the event, the "relatedObject" is the other BodyShape involved
		/// in the contact.
		public var relatedObject:BodyShape;
		
		/// Cached b2WorldManifold.
		public var worldManifold:b2WorldManifold = new b2WorldManifold();
		
		/// The world's step time the world manifold was calculated at. As long as this matches the
		/// current step time of the world, return the cached worldManifold.
		public var worldManifoldTime:int
		
		/// Indicates the "directionality" of the contact with respect to the fixture dispatching the event.
		/// if(fixture = contact.m_fixtureA) bias = 1.
		/// if(fixture = contact.m_fixtureB) bias = -1.
		public var bias:int;
		
		public function ContactEvent(t:String, p:int, w:EventWorld, a:b2Fixture, b:b2Fixture, bi:int, c:b2Contact = null) {
			super(t, true, true);
			world = w;
			contact = c ? c : new b2Contact(p, a, b);
			bias = bi;
			if(bi == 1) {
				fixture = a;
				other = b;
			}
			else {
				fixture = b;
				other = a;
			}
			relatedObject = other.m_userData as BodyShape;
		}
		
		/**
		 * Clone the event for re-dispatching.
		 */
		public override function clone():Event {
			return new ContactEvent(type, contact._ptr, world, bias == 1 ? fixture : other, bias == 1 ? other : fixture, bias, contact);
		}
		
		/**
		 * Disables a contact by setting it as a sensor for the life of the contact.
		 */
		public override function preventDefault():void {
			super.preventDefault();
			contact.SetSensor(true);
		}
		
		/**
		 * Returns true if the contacts is touching, is not a sensor, and has not been disabled.
		 */
		public function isSolid():Boolean {
			return contact.IsSolid();
		}
		
		/**
		 * Get the world normal of the contact that points from fixture to other.
		 */
		public function get normal():V2 {
			return getWorldManifold().m_normal;
		}
		
		/**
		 * Get the world point of contact (for 2-point contacts, this is the average).
		 */
		public function get point():V2 {
			return getWorldManifold().GetPoint();
		}
		
		/**
		 * Returns the world manifold. Very important if you plan on actually doing anything significant
		 * with contacts. The normal will be oriented based on "bias" so that it is always pointing from 
		 * the target fixture to the other fixture. This way you don't have to worry about the direction of the
		 * normal.
		 */
		public function getWorldManifold():b2WorldManifold {
			/// Return the cached world manifold if appropriate.
			if(!world.IsLocked() && worldManifoldTime == world.stepTime) {
				return worldManifold;
			}
			worldManifoldTime = world.stepTime;
			worldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);
			if(worldManifold.m_normal) {
				worldManifold.m_normal.multiplyN(bias);
			}
			return worldManifold;
		}
		
		/**
		 * Get the point count from the contact.
		 */
		public function getPointCount():uint {
			return contact.m_manifold.m_pointCount;
		}
	}
}