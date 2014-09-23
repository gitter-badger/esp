Expansive.load({
    meta: {
        title:       'Embedthis ESP Documentation',
        url:         'https://embedthis.com/esp/doc/',
        description: 'The amazing C web framework',
        keywords:    'esp, c web framework, web framework, mvc, web application, internet of things',
    },
    expansive: {
        copy: [ 'images' ],
        dependencies: { 'css/all.css.less': 'css/*.inc.less' },
        documents: [ '**', '!css/*.inc.less' ],
        plugins: [ 'less' ],
    }
})
