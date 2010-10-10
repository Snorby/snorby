// Snorby - A Web interface for Snort.
// 
// Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

var Snorby = {
	
	setup: {
		
		defaults: function(){

			$("#growl").notify({
			    speed: 500,
			    expires: 3000
			});

		},
		
	},
	
	pages: {
		
		events: function(){

			$('div.new_events').live('click', function() {
				$('#events table tbody.events tr').fadeIn('slow');
				$(this).remove();
				return false;
			});

		},
		
	},
	
	templates: {
		event_table: function(data){
			var template = " \
			{{#events}} \
			<tr id='event_{{sid}}{{cid}}' class='event' style='display:none;' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<td class='sensor first'>{{hostname}}</td> \
				<td class='severity'>{{severity}}</td> \
				<td class='src_ip'>{{ip_src}}</td> \
				<td class='src_port'>{{src_port}}</td> \
				<td class='dst_ip'>{{ip_dst}}</td> \
				<td class='dst_port'>{{dst_port}}</td> \
				<td class='signature'>{{message}}</td> \
				<td class='timestamp last'>{{timestamp}}</td> \
			</tr> \
			{{/events}}"
			return Mustache.to_html(template, data);
		},
	},
	
	notification: function(message){
		$('#growl').notify("create", message,{
		    expires: 3000,
		    speed: 500
		});
	},
	
	helpers: {
		
	}
	
}

jQuery(document).ready(function($) {
	
	Snorby.setup.defaults();
	Snorby.pages.events();
	
});
