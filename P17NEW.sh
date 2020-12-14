#!/bin/bash
#https://github.com/a18danperllu/Practica17/
#Menu
function usage () {
	cat <<EOF

	Usage: nomscript [-u usuari] [-h hostname] [-t]
		-c Usuari no existent
		-d Usuari ID inferior a 1000
		-r Eliminar compte d'user
		-a Deshabilitar un user però sense eliminar-lo
		-f Usuari a fer backup la home usuari
		-h Manual d'ajuda
EOF
exit 1
}
checkUser(){

	if [[ $(id -u $USER) -lt 1000 ]]
	then
		echo "L'usuari ${USER} és menor que 1.000"
	else
		echo "L'usuari ${USER} no és menor que 1.000"
		exit 1
	fi
}
#Comprobació de superuser (root).
if [[ "${UID}" -eq 0 ]]
then
	echo "Ets root"
else
	echo "Torna a intentar-ho com a root" >&2
	exit 1
fi
#Si no es passen paràmentres per teclat.
if [[ $# -eq 0 ]]
then
	usage
	exit 1
fi
#Opcions controlades per GETOPS
while getopts ":c:d:r:a:f:h" par;
do
	case $par in
	c) #Usuari no existent
		if getent passwd $1 > /dev/null 2>&1
		then
			echo "User existent"
			exit 1
		else
			echo "Usuari no existent al sistema"
			exit 1
		fi
	;;
	d) #Comprobacio si l'user es inferior a 1000
		USER="$OPTARG"
		checkUser
	;;
	r) #Esborrar compte d'usuari
		USER="$OPTARG"
		userdel ${USER}
	  #Comprobacio usuari esborrat
		if [[ "${?}" -ne 0 ]]
		then
			echo "Usuari ${USER} no esborrat." >&2
			exit 1
		else
			echo "El compte d'usuari ${USER} ha sigut esborrat."
			exit 1
		fi
	;;
	a) #Usuari a inhabilitar però no esborrar
		USER=$OPTARG
		if [[ checkUser =]]
		usermod -L ${USER}
		if [[ $? -eq 0 ]]
		then
			echo "Usuari ${USER} inhabilitat correctament."
		else
			echo "Usuari ${USER} no inhabilitat."
		fi
	;;
	f) #Usuari a fer backup
	;;
	h) #Menú d'ajuda
		#Esto hace que
		USER="$OPTARG"
		#Aixo fa que
		if [[ $? -eq 0 ]]
		then
			usage
		fi
	;;
	#Missatges d'error
	:)
		echo "ERROR: -$OPTARG requereix d'un argument.\n"
	;;
	\?)
		echo "ERROR: Opció -$OPTARG invàlida"
		usage
	;;
	*)
		echo "ERROR: Error no identificat\n"
	;;
	esac
done
#Esborrar les opcions quan abandonem els restants arguments
shift "$(( OPTIND -1 ))"
