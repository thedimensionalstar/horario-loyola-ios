# Añade el widget "Próxima clase" (extensión de WidgetKit) al proyecto de Xcode que crea Capacitor.
# Uso: ruby scripts/add-widget.rb ios/App/App.xcodeproj
require 'xcodeproj'

project_path = ARGV[0] || 'ios/App/App.xcodeproj'
name = 'HorarioWidget'
project = Xcodeproj::Project.open(project_path)

if project.targets.any? { |t| t.name == name }
  puts "El widget ya estaba en el proyecto."
  exit 0
end

app = project.targets.find { |t| t.name == 'App' } or abort('No se encontró el target App.')
app_id = app.build_configurations.first.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
abort('El target App no tiene PRODUCT_BUNDLE_IDENTIFIER.') if app_id.nil? || app_id.empty?

widget = project.new_target(:app_extension, name, :ios, '17.0', nil, :swift)

group = project.main_group.new_group(name, name)
swift = group.new_reference('HorarioWidget.swift')
group.new_reference('Info.plist')
widget.add_file_references([swift])

widget.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = "#{app_id}.widget"
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{name}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SWIFT_VERSION'] = '5.0'
  s['MARKETING_VERSION'] = app.build_configurations.first.build_settings['MARKETING_VERSION'] || '1.0'
  s['CURRENT_PROJECT_VERSION'] = app.build_configurations.first.build_settings['CURRENT_PROJECT_VERSION'] || '1'
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

app.add_dependency(widget)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(widget.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Justo después de "Resources" para evitar ciclos con fases de script.
app.build_phases.move(embed, app.build_phases.index(app.resources_build_phase) + 1)

project.save
puts "✓ Widget añadido (#{app_id}.widget)"
