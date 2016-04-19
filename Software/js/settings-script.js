//Load Settings
if (localStorage.length == 0) {
	localStorage.setItem('color', 'Username');
	localStorage.setItem('size', 'Number of Retweets');
	localStorage.setItem('cluster', 'Hashtags');
	localStorage.setItem('limit', '300');
}

$('#color-column-picker').val(localStorage.getItem('color'));
$('#color-column-picker').selectpicker('refresh');

$('#size-column-picker').val(localStorage.getItem('size'));
$('#size-column-picker').selectpicker('refresh');

$('#cluster-column-picker').val(localStorage.getItem('cluster'));
$('#cluster-column-picker').selectpicker('refresh');

$('#limit-picker').val(localStorage.getItem('limit'));
$('#limit-picker').selectpicker('refresh');

//Color Modal Configurations
$('#color-cancel').on('click', function () {
	$('#color-column-picker').val(localStorage.getItem('color'));
	$('#color-column-picker').selectpicker('refresh');
});

$('#color-exit').on('click', function () {
	$('#color-column-picker').val(localStorage.getItem('color'));
	$('#color-column-picker').selectpicker('refresh');
});

$('#color-save').on('click', function () {
	var data = $('#color-column-picker option:selected').text();
	localStorage.setItem('color', data);

	$("#hidden-settings-button").click();
});

//Size Modal Configurations
$('#size-cancel').on('click', function () {
	$('#size-column-picker').val(localStorage.getItem('size'));
	$('#size-column-picker').selectpicker('refresh');
});

$('#size-exit').on('click', function () {
	$('#size-column-picker').val(localStorage.getItem('size'));
	$('#size-column-picker').selectpicker('refresh');
});

$('#size-save').on('click', function () {
	var data = $('#size-column-picker option:selected').text();
	localStorage.setItem('size', data);

	$("#hidden-settings-button").click();
});

//Cluster Modal Configurations
$('#cluster-cancel').on('click', function () {
	$('#cluster-column-picker').val(localStorage.getItem('cluster'));
	$('#cluster-column-picker').selectpicker('refresh');
});

$('#cluster-exit').on('click', function () {
	$('#cluster-column-picker').val(localStorage.getItem('cluster'));
	$('#cluster-column-picker').selectpicker('refresh');
});

$('#cluster-save').on('click', function () {
	var data = $('#cluster-column-picker option:selected').text();
	localStorage.setItem('cluster', data);

	$("#hidden-settings-button").click();
});

//Limit Modal Configurations
$('#limit-cancel').on('click', function () {
	$('#limit-picker').val(localStorage.getItem('limit'));
	$('#limit-picker').selectpicker('refresh');
});

$('#limit-exit').on('click', function () {
	$('#limit-picker').val(localStorage.getItem('limit'));
	$('#limit-picker').selectpicker('refresh');
});

$('#limit-save').on('click', function () {
	var data = $('#limit-picker option:selected').text();
	localStorage.setItem('limit', data);

	$("#hidden-settings-button").click();
});