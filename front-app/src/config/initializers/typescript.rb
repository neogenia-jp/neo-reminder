TypeScript::Src.use_external_tsc = true

Typescript::Rails::Compiler.default_options = [
    '--target', 'ES5',
    '--module', 'system',
#    '--strict', 'true',
#    '--noImplicitThis'
]
