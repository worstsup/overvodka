package  {
	
	import flash.display.MovieClip;
	
	import ValveLib.Globals;
				
	public class CustomError extends MovieClip {
		
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		
		public function CustomError() {
			//constructor
		}
		
		public function onLoaded() : void {			
			//make this UI visible
			visible = true;

			//add our event listener
			this.gameAPI.SubscribeToGameEvent("custom_error_show", this.showError);	
		}

		public function showError( args:Object ){
			// get the pID of the owner of this UI
			var pID:int = this.globals.Players.GetLocalPlayer();

			// check if the owner of this UI is the same as the player passed by the event
			if( pID == args.player_ID ) {
				// last but not least, utilise the error_msg panel to show our custom error message
				this.globals.Loader_error_msg.movieClip.setErrorMsg(args._error);
			}
		}
	}
	
}