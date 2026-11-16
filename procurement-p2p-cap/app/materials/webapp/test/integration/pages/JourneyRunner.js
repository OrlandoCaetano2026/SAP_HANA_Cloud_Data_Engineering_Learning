sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"p2p/materials/test/integration/pages/MaterialsList.gen",
	"p2p/materials/test/integration/pages/MaterialsObjectPage.gen"
], function (JourneyRunner, MaterialsListGenerated, MaterialsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('p2p/materials') + '/test/flp.html#app-preview',
        pages: {
			onTheMaterialsListGenerated: MaterialsListGenerated,
			onTheMaterialsObjectPageGenerated: MaterialsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

