<div class="container">
	<div class="col-sm-12 col-md-12 main">
		<table class="table sortable">
			<tr>
				<th class="col-lg-1">#</th>
				<th class="col-lg-1">Actions</th>
				<th class="col-lg-1">Domain</th>
				<th class="col-lg-1">Hostname</th>
				<th class="col-lg-1">Username</th>
				<th class="col-lg-1">Full Name</th>
				<th class="col-lg-1">Stat</th>
				<th class="col-lg-1">Dis</th>
				<th class="col-lg-1">Lock</th>
				<th class="col-lg-1">Exp</th>
				<th class="col-lg-1">Chg</th>
				<th class="col-lg-1">Req</th>				
			</tr>
			{{users}}
			
		</table>
		
		
		
	</div>
</div>
<script>
csts.onLoad( function(){

	csts.setHeader('Manage Local Administrators');

	jQuery('#myTabs a').click(function (e) {
		e.preventDefault();
		jQuery(this).tab('show');
	});

	jQuery('#myTabs a[href="#scap"]').tab('show');
});
</script>	