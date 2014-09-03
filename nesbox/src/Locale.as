package
{
	public class Locale
	{
		private static var instanceValue:Locale;
		
		public function Locale()
		{
			
		}
		
		public static function get instance():Locale
		{
			if(!instanceValue)
			{
				instanceValue = new Locale;
				instanceValue.init();
			}
			
			return instanceValue;
		}
		
		private function init():void
		{

		}
		
		public var click_here_to_play_the_game:String;
		public var error_occured:String;
		public var close:String;
		public var cancel:String;
		public var click_allow_button:String;
		public var now_connect_gamepad:String;
		public var configure:String;
		public var or:String;
		public var press:String;
		public var button:String;
		public var connecting_please_wait:String;
		public var if_you_want_to_use_gamepad:String;
		public var user_name:String;
		public var email:String;
		public var password:String;
		public var forgot_password:String;
		public var sign_in:String;
		public var sign_up:String;
		public var to_save_load_game_you_need:String;
		public var keyboard_setup:String;
		public var select_joystick_button:String;
		public var load_defaults:String;
		public var save:String;
		public var select_mode:String;
		public var one_player:String;
		public var two_players_via_internet:String;
		public var game_walkthrough:String;
		public var your_own_server:String;
		public var supported_rom_formats:String;
		public var click_here_to_load_your_own_rom:String;
		public var loading_module:String;
		public var loading_game:String;
		public var loading_emulator:String;
		public var uploading_walkthrough:String;
		public var please_wait:String;
		public var you_already_have_saved_walkthrough:String;
		public var yes:String;
		public var no:String;
		public var you_need_to_be_signed_in_to_upload_walk:String;
		public var waiting_for_connection:String;
		public var if_you_cannot_connect:String;
		public var connecting_to_server:String;
		public var new_send_copied_url:String;
		public var also_you_can_find_partner:String;
		public var public_chat:String;
		public var remote_url:String;
		public var click_here_to_copy_url_to_clipboard:String;
		public var then_send_it_to_friend:String;
		public var connected_to_server:String;
		public var connection_error:String;
		public var testing_connection:String;
		public var ping_is:String;
		public var the_game_will_be_uncomfortable:String;
		public var saving_game:String;
		public var you_have_saved_state:String;
		public var do_you_want_to_load_state:String;
		public var you_need_to_be_signed_in_to_save:String;
		public var loading_walkthrough:String;
		
		public var gamepad_app_info:String;
		public var gamepad_app_downloaded:String;
		public var click_here_to_save_it:String;
		
		public var hint_pause:String;
		public var hint_setup:String;
		public var hint_mute:String;
		public var hint_load:String;
		public var hint_save:String;
		public var hint_fullscreen:String;
		public var hint_share:String;
		public var hint_upload:String;
		public var hint_gamepad:String;
		public var hint_favorite:String;
		public var server_setup:String;
		public var server_port:String;
		public var server_frameskip:String;
		public var connect:String;
		public var server_connection_error:String;
		public var make_sure_entered_correct_ip:String;
		public var try_again:String;
		public var you_are_connected:String;
		public var and_send_to_friend:String;
		public var remote_url_is:String;
		public var connection_has_closed:String;
		
		public var please_read:String;
		public var how_start_own_server:String;
		
		public function sprintf(buffer:String, ...args):String
		{
			for(var index:int = 0; index < args.length; index++)
				buffer = buffer.split('%'+(index+1)+'%').join(args[index]);
			
			return buffer;
		}
	}
}
