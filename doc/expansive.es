Expansive.load({
    meta: {
        title:       'Embedthis ESP Documentation',
        url:         'https://embedthis.com/esp/doc/',
        description: 'The amazing C web framework',
    },
    expansive: {
        copy: [ 'images' ],
        dependencies: { 'css/all.css.less': '**.less' },
        documents: [ '**', '!**.less', '**.css.less' ],
        plugins: [ 'less' ],
    }
})
