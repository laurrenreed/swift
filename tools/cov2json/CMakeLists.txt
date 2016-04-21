add_swift_executable(cov-compare
  ProfdataCompare.cpp
  JSONWriter.cpp
  Utils.cpp
  main.cpp
  LINK_LIBRARIES swiftBasic
  COMPONENT_DEPENDS support object profiledata "option" core)

swift_install_in_component(compiler
    TARGETS cov-compare
    RUNTIME DESTINATION "bin")

