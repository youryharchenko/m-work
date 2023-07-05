project('gui', 'vala', 'c',
  version : '0.1',
)

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gio-2.0'),
    dependency('libgda-5.0'),
    #dependency('libgdaui-5.0'),
    dependency('libxml-2.0'),
    #meson.get_compiler('vala').find_library('mysql'),
    #meson.get_compiler('c').find_library('mysqlclient'),
    
    #dependency('gio-unix-2.0'),
    #dependency('json-glib-1.0'),
    #meson.get_compiler('vala').find_library('sdl-gfx'),
    #meson.get_compiler('c').find_library('SDL_gfx'),
    #meson.get_compiler('c').find_library('m'),
]

sources = files('src/main.vala')

exe = executable('gui', sources, dependencies: dependencies)

#test('basic', exe)
