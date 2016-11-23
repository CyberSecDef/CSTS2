<div class="container">
	<div class="col-sm-12 col-md-12 main">
		<form >
			<div>
				<ul id="myTabs" class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#scap" aria-controls="scap" role="tab" data-toggle="tab">SCAP</a></li>
					<li role="presentation"><a href="#gpo" aria-controls="gpo" role="tab" data-toggle="tab">GPO</a></li>
					<li role="presentation"><a href="#pol" aria-controls="pol" role="tab" data-toggle="tab">POL</a></li>
					<li role="presentation"><a href="#selections" aria-controls="selections" role="tab" data-toggle="tab">Selections</a></li>
				</ul>  
				<br />
				<div class="tab-content">
					<div role="tabpanel" class="tab-pane active" id="scap">
						<label for="fileXccdf">SCAP XCCDF</label>
						<div class="input-group">
							<label class="input-group-btn">
								<span class="btn btn-primary">
									Browse&hellip; <input type="file" style="display: none;">
								</span>
							</label>
							<input type="text" class="form-control" readonly="readonly">
						</div>
						<br />

						<label>SCAP OVAL</label>
						<div class="input-group">
							<label class="input-group-btn">
								<span class="btn btn-primary">
									Browse&hellip; <input type="file" style="display: none;">
								</span>
							</label>
							<input type="text" class="form-control" readonly="readonly">
						</div>
						<br />
						
						<label>SCAP Profile</label>
						<select class="form-control">
							<option>Unclassified - Sensitive</option>
						</select>

						<br />
						<div class="form-group">
							<div class="col-sm-offset-4 col-sm-4">
								<button type="button" class="btn btn-lg btn-primary">Add</button>
							</div>
						</div>
						
					</div>
					
					<div role="tabpanel" class="tab-pane" id="gpo">
						<label>User GPO</label>
						<select class="form-control">
							<option>Some GPO</option>
						</select>

						<label>Machine GPO</label>
						<select class="form-control">
							<option>Some GPO</option>
						</select>					
						<br />
						<div class="form-group">
							<div class="col-sm-offset-4 col-sm-4">
								<button type="button" class="btn btn-lg btn-primary">Add</button>
							</div>
						</div>
					</div>
					
					<div role="tabpanel" class="tab-pane" id="selections">
						<table class="table table-striped">
							<tr>
								<th>#</th>
								<th>Type</th>
								<th>Path</th>
							</tr>
						</table>

						<div class="form-group">
							<div class="col-sm-offset-4 col-sm-4">
								<button type="button" class="btn btn-block btn-lg btn-primary">Execute</button>
							</div>
						</div>			
					</div>
				</div>
			</div>
		</form>
	</div>
</div>
<script>
csts.onLoad( function(){

	csts.setHeader('Apply Policies');

	jQuery(document).on('change', ':file', function() {
		var input = $(this),
		numFiles = input.get(0).files ? input.get(0).files.length : 1,
		label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
		input.trigger('fileselect', [numFiles, label]);
	});


	jQuery(':file').on('fileselect', function(event, numFiles, label) {
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;

		if( input.length ) {
			input.val(log);
		} else {
			if( log ){
				alert(log);
			}
		}
	});


	jQuery('#myTabs a').click(function (e) {
		e.preventDefault();
		jQuery(this).tab('show');
	});

	jQuery('#myTabs a[href="#scap"]').tab('show');
});
</script>	