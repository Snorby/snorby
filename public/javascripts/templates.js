(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['search-rule'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<div class=\"search-content-box\">\n  <div class=\"inside\">\n\n    <div class=\"search-content-enable search-content-box-item\">\n      <input name=\"enable-current-search-content\" checked='checked' type=\"checkbox\" />\n    </div>\n\n    <div class=\"column-select search-content-box-item\">\n      <select class='add_chosen'>\n        <option value='any'>Any</option>\n        <option value='all'>All</option>\n      </select> \n    </div>\n\n    <div class=\"operator-select search-content-box-item\">\n      <select class='add_chosen'>\n        <option value='is'>is</option>\n        <option value='is_not'>is not</option>\n      </select>      \n    </div>\n\n    <div class=\"value search-content-box-item\">\n      <input class='search-content-value' placeholder=\"Enter search value\" name=\"\" type=\"text\" /> \n    </div>\n\n    <div class=\"search-button-box-holder\">\n      <div class=\"search-button-box-inside\">\n        <div class=\"search-button-box\">\n\n          <div title='Remove search rule' class=\"search-content-remove search-content-box-item\">\n            <img src=\"/images/icons/minus.png\" alt=\"\" />\n          </div>\n\n          <div title='Add new search rule' class=\"search-content-add search-content-box-item\">\n            <img src=\"/images/icons/add.png\" alt=\"\" />\n          </div>\n\n        </div>\n      </div>\n    </div>\n\n  </div>\n</div>\n";});
templates['search'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;


  buffer += "<div id=\"search\" class=\"boxit page grid_12\">\n\n  <div class=\"search-match-box\" style=\"display:;\">\n    Match \n    <select class=\"global-match-setting\">\n      <option value=\"any\">Any</option>\n      <option value=\"all\" selected=\"selected\">All</option>\n    </select> \n    of the following rules: \n  </div>\n\n  <div class=\"other-search-options\" style=\"display:none;\">\n    <input name=\"limit-all-search-rules\" type=\"checkbox\"> \n    Limit to\n    <input class=\"limit-search-results-count\" name=\"limit-search-results-to\" type=\"text\" value=\"10000\"> \n    ordered by\n    <select><option value=\"any\">Event Timestamp</option><option value=\"all\">All</option></select>\n    <br>\n    <input name=\"ignore-classified-events\" type=\"checkbox\"> Ignore all classified events.\n  </div>\n\n  <div class=\"rules\"></div>\n\n  <div id=\"form-actions\">\n    <button class=\"";
  foundHelper = helpers.cssClass;
  stack1 = foundHelper || depth0.cssClass;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "cssClass", { hash: {} }); }
  buffer += escapeExpression(stack1) + " success default\"><span>";
  foundHelper = helpers.buttonTitle;
  stack1 = foundHelper || depth0.buttonTitle;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "buttonTitle", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</span></button>\n  </div>\n</div>\n";
  return buffer;});
templates['select'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, stack2, foundHelper, tmp1, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression, blockHelperMissing=helpers.blockHelperMissing;

function program1(depth0,data) {
  
  
  return "multiple";}

function program3(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "style=\"width:";
  foundHelper = helpers.width;
  stack1 = foundHelper || depth0.width;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "width", { hash: {} }); }
  buffer += escapeExpression(stack1) + ";\"";
  return buffer;}

function program5(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "data-placeholder=\"";
  foundHelper = helpers.placeholder;
  stack1 = foundHelper || depth0.placeholder;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "placeholder", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\"";
  return buffer;}

function program7(depth0,data) {
  
  
  return "<option value=\"\"></option>";}

function program9(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n    <option value=\"";
  foundHelper = helpers.id;
  stack1 = foundHelper || depth0.id;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "id", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">";
  foundHelper = helpers.value;
  stack1 = foundHelper || depth0.value;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "value", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</option>\n  ";
  return buffer;}

  buffer += "<select ";
  foundHelper = helpers.multiple;
  stack1 = foundHelper || depth0.multiple;
  stack2 = helpers['if'];
  tmp1 = self.program(1, program1, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " ";
  foundHelper = helpers.width;
  stack1 = foundHelper || depth0.width;
  stack2 = helpers['if'];
  tmp1 = self.program(3, program3, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += " \n  class=\"add_chosen\" \n  ";
  foundHelper = helpers.placeholder;
  stack1 = foundHelper || depth0.placeholder;
  stack2 = helpers['if'];
  tmp1 = self.program(5, program5, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n  name=\"";
  foundHelper = helpers.name;
  stack1 = foundHelper || depth0.name;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "name", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">\n\n  ";
  foundHelper = helpers.placeholder;
  stack1 = foundHelper || depth0.placeholder;
  stack2 = helpers['if'];
  tmp1 = self.program(7, program7, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n\n  ";
  foundHelper = helpers.data;
  stack1 = foundHelper || depth0.data;
  stack1 = (stack1 === null || stack1 === undefined || stack1 === false ? stack1 : stack1.value);
  tmp1 = self.program(9, program9, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  if(foundHelper && typeof stack1 === functionType) { stack1 = stack1.call(depth0, tmp1); }
  else { stack1 = blockHelperMissing.call(depth0, stack1, tmp1); }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n</select>\n\n\n";
  return buffer;});
})();