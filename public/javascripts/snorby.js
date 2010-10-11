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
	
	setup: function(){

		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});

	},
	
	pages: {
		
		events: function(){

			// Row Select
			// $('table tbody.events tr.event').live('click', function() {
			// 	var sid = $(this).attr('data-event-sid');
			// 	var cid = $(this).attr('data-event-cid');
			// 	var current_row = $(this);
			// 	
			// 	if ($('table tbody.events tr#event-data-'+sid+''+cid).is(':visible')) {
			// 		$('table tbody.events tr#event-data-'+sid+''+cid+' div.event-data-holder').slideUp('fast', function () {
			// 			$('table tbody.events tr#event-data-'+sid+''+cid).hide();
			// 		});
			// 	} else {
			// 		$.get('/events/show/'+sid+'/'+cid, function (data) {
			// 			current_row.after(Snorby.templates.event_data(data));
			// 			$('table tbody.events tr#event-data-'+sid+''+cid+' div.event-data-holder').slideDown('fast');
			// 		});
			// 	};
			// 	
			// 	return false;
			// });

			$('div.new_events').live('click', function() {
				$('#events table tbody.events tr').fadeIn('slow');
				$(this).remove();
				return false;
			});

		},
		
	},
	
	templates: {
		
		event_data: function(data){
			var template = " \
			<tr id='event-data-{{sid}}{{cid}}' class='event-data' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<td class='first last' colspan='7'> \
				 	<div class='event-data-holder' style='display:none;'> \
						<pre>{{payload}}</pre>\
					</div> \
				</td> \
			</tr>"
			return Mustache.to_html(template, data);
		},
		
		event_table: function(data){
			var template = " \
			{{#events}} \
			<tr id='event_{{sid}}{{cid}}' class='event' style='display:none;' data-event-id='{{sid}}{{cid}}' data-event-sid='{{sid}}' data-event-cid='{{cid}}'> \
				<td class='select first'><input class='event-selector' id='event-selector' name='event-selector' type='checkbox'></td> \
				<td class='severity'>{{severity}}</td> \
				<td class='sensor'>{{hostname}}</td> \
				<td class='src_ip'>{{ip_src}}</td> \
				<td class='dst_ip'>{{ip_dst}}</td> \
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
	
	Snorby.setup();
	Snorby.pages.events();
	
});
