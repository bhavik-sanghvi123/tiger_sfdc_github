({
	executeGetPath : function(component) {
		var action = component.get('c.getPath');		
		action.setParams({
			'recId' : component.get('v.recordId')
		})

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				component.set('v.statusPathList', response.getReturnValue());
			}else {
				console.log(response.getError()[0].message);
			}
		});

		$A.enqueueAction(action);
	}
})