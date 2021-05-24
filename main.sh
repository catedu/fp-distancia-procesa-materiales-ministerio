#!/bin/bash
###########################################################
#
#
#
############################################################

#####
# Funciones
#####
procesa_elps(){
    #parametros
    elp=${1}
    ciclo=${2}
    modulo=${3}
    entorno=${4}
    # calculados
    tema="${elp//[^0-9]/}"
    echo "tema: ${tema}"
    # 
    if ! [ -d /home/pablo/Descargas/temp/${entorno}/${ciclo} ]; then
        mkdir /home/pablo/Descargas/temp/${entorno}/${ciclo}
    fi
    if ! [ -d /home/pablo/Descargas/temp/${entorno}/${ciclo}/${modulo} ]; then
        mkdir /home/pablo/Descargas/temp/${entorno}/${ciclo}/${modulo}
    fi

    exe_do --export=website "/home/pablo/Descargas/temp/${entorno}/${elp}" "/home/pablo/Descargas/temp/${entorno}/${ciclo}/${modulo}/${tema}/"
}
#

#####
# Main
#####

PWD="/home/pablo/Descargas/CONTENIDOS_2020-21"
echo "PWD: ${PWD}"
#Extraigo de las carpetas los elps de contenidos
for x in ${PWD}/*/
do
    my_array=($(echo $x | tr "/" "\n"))
    ult_carpeta=""
    for i in "${my_array[@]}"
    do
        ult_carpeta=$i
    done
    my_array=($(echo $ult_carpeta | tr "_" "\n"))
    ciclo=${my_array[0]}
    modulo=${my_array[1]}

    for y in ${x}/Fuentes/
    do
        # echo "${y}"
        for fichero in ${y}/*.zip
        do
            # echo "**Fichero: ${fichero}"
            for entorno in "Contenidos" "Tarea" "OrientacionesAlumnado"
            do
                elp=$(unzip -l ${fichero} | grep "${entorno}.elp" | rev | cut -d ' ' -f 1 | rev)
                # echo "elp: ${elp}"
                elp_file=$(echo $elp | rev | cut -d '/' -f 1 | rev )
                # echo "elp_file: ${elp_file}"
                if [ -n "$elp" ]; then
                    if ! [ -d /home/pablo/Descargas/temp/${entorno} ]; then
                        mkdir /home/pablo/Descargas/temp/${entorno}
                    fi
                    unzip -u -j "${fichero}" "${elp}" -d "/home/pablo/Descargas/temp/${entorno}" # && /
                    # mv "/home/pablo/Descargas/temp/${elp_file}" "/home/pablo/Descargas/temp/${ciclo}_${modulo}_${elp_file}"
                    procesa_elps "${elp_file}" "${ciclo}" "${modulo}" "${entorno}"
                else
                    echo "=====> ERROR procesando el fichero ${fichero} en el entorno ${entorno}"
                fi
            done
            
        done
    done
done

# llevo al servidor los cambios
# rsync -avzh -e 'ssh -p 22987' /home/pablo/Descargas/temp/* debian@135.125.98.101:/var/moodle-docker-deploy/test.adistanciafparagon.es/moodle-code/materiales