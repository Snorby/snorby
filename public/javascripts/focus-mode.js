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

var FocusMode;

FocusMode = function() {

  function FocusMode() {
    var self = this;

    self.enabled = false;

    self.css = {
      minWidth: '990px',
      position: 'absolute !important',
      top: '0',
      bottom: '0',
      right: '0',
      left: '0',
      zIndex: 998,
      '-webkit-box-shadow': '0px 0px 20px rgba(0,0,0,0.3)',
      '-moz-box-shadow': '0px 0px 20px rgba(0,0,0,0.3)',
      'box-shadow': '0px 0px 20px rgba(0,0,0,0.3)',
      border: "1px solid #000",
      visibility: 'visible',
      display: 'block',
    };

    return self;
  };

  FocusMode.prototype = {
  
    //
    //
    //
    open: function() {
      var self = this;
      self.enabled = true;

      self.$old_event.after(self.$event);

      self.$event.find('div.event-data-holder-inside, div.event-data-holder, div.event-data').css({
        height: 'auto',
        height: '100%'
      });

      self.$event.find('div.row').css({
        borderLeft: "none",
        borderRight: "none"
      });

      self.$event.find('div.event-data-holder-inside').css({
        borderTop: "1px solid #000"
      });

      self.$event.find('div.event-data-holder').css({
        border: "none"
      });

      self.$event.css(self.css);

    },

    //
    //
    //
    close: function() {
      var self = this;
      self.enabled = false;
      self.$event.remove();
      self.$event = null;
      $('body div.focus-mode-overlay').remove();
    },

    //
    // Fetch Event
    //
    fetch: function(obj) {
      var self = this;
      self.$old_event = $(obj).parents('li.event')
      self.$event = self.$old_event.clone();
    },

    //
    // Toggle
    //
    toggle: function(obj) {
      var self = this;

      if (!self.$event) {
        self.fetch(obj);
      };

      self.$event.addClass('event-clone').css({
        display: 'none',
        visibility: 'hidden',
      });

      if (self.enabled) {
        self.close();
      } else {
        self.open();
      };
    },

    //
    //
    //
    next: function() {
      var self = this; 
    },

    //
    //
    //
    previous: function() {
      var self = this; 
    },

  };

  return FocusMode;
}();


var SFM = new FocusMode();

$('a.event-focus-mode').live('click', function(e) {
  e.preventDefault();
  SFM.toggle(this);
});

//<li class=''>
//  <a href="#" class='dark-button event-focus-mode'>
//    <img class='focus-mode' src="../images/icons/focus-mode.png" width='12px' height='11px' alt="" />
//  </a>
//</li>
