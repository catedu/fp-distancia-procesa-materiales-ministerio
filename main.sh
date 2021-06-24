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

    exe_do --export=website --editable "/home/pablo/Descargas/temp/${entorno}/${elp}" "/home/pablo/Descargas/temp/${entorno}/${ciclo}/${modulo}/${tema}/"
}
#

#####
# Main
#####

PWD="/home/pablo/fp-distancia-procesa-materiales-ministerio"
echo "PWD: ${PWD}"
#Extraigo de las carpetas los elps de contenidos
for x in ${PWD}/*/
do
    echo "x: ${x}"
    my_array=($(echo $x | tr "/" "\n"))
    echo "my_array: ${my_array}"
    ult_carpeta=""
    for i in "${my_array[@]}"
    do
        ult_carpeta=$i
    done
    echo "ult_carpeta: ${ult_carpeta}"
    my_array=($(echo $ult_carpeta | tr "_" "\n"))
    ciclo=${my_array[0]}
    modulo=${my_array[1]}
    echo "ciclo: ${ciclo}"
    echo "modulo: ${modulo}"

    for y in ${x}/Fuentes/
    do
        echo "*y: ${y}"
        for fichero in ${y}/*.zip
        do
            echo "**Fichero: ${fichero}"
            # for entorno in "Contenidos" "Tarea" "OrientacionesAlumnado"
            for entorno in "ontenid"
            do
                elp=$(unzip -l ${fichero} | grep '\.elp' | grep ${entorno} | rev | cut -d ' ' -f 1 | rev)
                echo "***elp: ${elp}"
                num_lineas=$(unzip -l ${fichero} | grep '\.elp' | grep ${entorno} | rev | cut -d ' ' -f 1 | rev | wc -l )
                echo "***num_lineas: ${num_lineas}"
                elp_file=""
                if [[ "${num_lineas}" = "1" ]];
                then
                    elp_file=$(echo $elp | rev | cut -d '/' -f 1 | rev )
                else
                    coincidencias=($(echo $elp | tr " " "\n"))
                    echo "Ficheros disponibles:"
                    COUNTER=0
                    for coincidencia in "${coincidencias[@]}"
                    do
                        echo "[${COUNTER}] ${coincidencia}"
                        let COUNTER=COUNTER+1
                    done
                    echo "Seleccione línea a procesar"
                    read linea_procesar
                    echo "La línea a procesar es la línea ${linea_procesar} que se corresponde con ${coincidencias[${linea_procesar}]}"
                    elp=${coincidencias[${linea_procesar}]}
                    elp_file=$(echo $elp | rev | cut -d '/' -f 1 | rev )
                fi
                echo "***elp_file: ${elp_file}"
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