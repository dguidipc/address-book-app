include(FindGettext)

set(DOMAIN address-book-app)
set(POT_FILE ${DOMAIN}.pot)
file(GLOB PO_FILES *.po)
file(GLOB_RECURSE I18N_SRCS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/*.qml)
list(SORT I18N_SRCS)

file(RELATIVE_PATH DESKTOP_FILE_IN_IN ${CMAKE_CURRENT_SOURCE_DIR}
     ${CMAKE_SOURCE_DIR}/data/${DESKTOP_FILE}.in.in)

foreach(PO_FILE ${PO_FILES})
    get_filename_component(LANG ${PO_FILE} NAME_WE)
    gettext_process_po_files(${LANG} ALL PO_FILES ${PO_FILE})
    set(INSTALL_DIR ${CMAKE_INSTALL_LOCALEDIR}/${LANG}/LC_MESSAGES)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.gmo
            DESTINATION ${INSTALL_DIR}
            RENAME ${DOMAIN}.mo)
endforeach(PO_FILE)

find_program(XGETTEXT_EXECUTABLE xgettext)
if(XGETTEXT_EXECUTABLE)
    add_custom_target(${POT_FILE} ALL
        COMMENT "Generating translation template"
        COMMAND ${INTLTOOL_EXTRACT} --update --type=gettext/ini
                --srcdir=${CMAKE_CURRENT_SOURCE_DIR} ${DESKTOP_FILE_IN_IN}

        COMMAND ${XGETTEXT_EXECUTABLE} -o ${POT_FILE}
                --c++ --qt --add-comments=TRANSLATORS
                --keyword=tr --keyword=tr:1,2
                --keyword=dtr:2 --keyword=dtr:2,3
                --keyword=N_
                --package-name=${DOMAIN}
                --copyright-holder='Canonical Ltd.'
                -s -p ${CMAKE_CURRENT_SOURCE_DIR}
                -D ${CMAKE_CURRENT_SOURCE_DIR} ${I18N_SRCS}
                -D ${CMAKE_CURRENT_BINARY_DIR} ${DESKTOP_FILE_IN_IN}.h
    )

    add_custom_target(translations
        COMMENT "Updating translation files"
    )

    add_dependencies(translations ${POT_FILE})
    foreach(PO_FILE ${PO_FILES})
       add_custom_command(TARGET translations
            COMMAND ${GETTEXT_MSGMERGE_EXECUTABLE} ${PO_FILE} ${CMAKE_CURRENT_SOURCE_DIR}/${POT_FILE} -o ${PO_FILE}
       )
    endforeach(PO_FILE)

endif()
