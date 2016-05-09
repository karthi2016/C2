// Generated by CoffeeScript 1.9.1
this.setupC2TestParams = function() {
  return {
    editMode: getEditModeContent(),
    formState: getRequestDetailsForm(),
    detailsForm: getRequestDetailsForm(),
    detailsSave: getRequestDetailsForm(),
    attachmentCard: getAttachmentContent(),
    observerCard: getObserverContent(),
    actionBar: getActionBarContent()
  };
};

this.getEditModeContent = function() {
  return $('<div class="view-mode" id="mode-parent"></div>');
};

this.getAttachmentContent = function() {
  return $('<div class="card-for-attachments"></div>').html('<label for="attachment_file" class="attachment-label">file label</label> <form id="new_attachment"> <input id="attachment_file" type="file"> <button type="submit"> </form> <ul class="attachment-list"></ul>');
};

this.getActionBarContent = function() {
  return $('<div class="action-bar-template action-bar-wrapper"> <ul id="request-actions"> <li class="cancel-button"> <input type="button" value="Cancel"> </li> <li class="save-button"> <input type="button" value="Save"> </li> </ul> </div>');
};

this.getRequestDetailsForm = function() {
  return $('<div id="request-details-card"> <form> <label> <input id="field_1"> </label> <label> <input id="field_2"> </label> <input id="submit" type="Submit"> </form> </div>');
};

this.getObserverContent = function() {
  return $('<div class="card-for-observers"> <ul class="observer-list"></ul> <form class="new_observation" id="new_observation"> <select id="observation_user_id" class="js-selectize"> <option value="user1@test.com">user1@test.com</option> </select> <input class="form-field" data-hide-until-select="observation_user_id" type="text" name="observation[reason]" id="observation_reason"> </div>');
};
