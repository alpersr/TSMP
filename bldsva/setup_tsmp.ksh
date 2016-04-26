#! /bin/ksh
getDefaults(){
  def_platform=""               
  def_version=""                 
  def_rootdir="$estdir"    #This should be correct - change with caution
  def_combination=""           
  def_refSetup=""
  def_bindir=""				#Will be set to $rootdir/bin/$platform_$version_$combination if empty
  def_rundir=""  			#Will be set to $rootdir/run/$platform_${version}_$combination_$refSetup_$date if empty
  def_pfldir=""
  def_numInst=""
  def_startInst=""
  # following parameters  will be set to tested platform defaults if empty
  def_nppn=""
  def_wtime=""
  ## following parameters  will be set to tested setup defaults if empty
  def_namelist_clm=""
  def_namelist_cos=""
  def_namelist_oas=""
  def_namelist_pfl=""
  def_forcingdir_clm=""
  def_forcingdir_cos=""
  def_forcingdir_oas=""
  def_forcingdir_pfl=""
  def_queue=""
  def_px_clm=""
  def_py_clm=""
  def_px_cos=""
  def_py_cos=""
  def_px_pfl=""
  def_py_pfl=""
  def_startDate=""
  def_restDate=""
  def_runhours=""
  #profiling ("yes" , "no") - will use machine standard
  def_profiling="no"
}

setDefaults(){
  platform=$def_platform
  if [[ $platform == "" ]] then ; platform="CLUMA2" ; fi #We need a hard default here
  version=$def_version
  if [[ $version == "" ]] then ; version="1.1.0MCT" ; fi #We need a hard default here
  bindir=$def_bindir
  rundir=$def_rundir
  profiling=$def_profiling
  rootdir=$def_rootdir
  pfldir=$def_pfldir
  log_file=$cpwd/log_all_${date}.txt
  err_file=$cpwd/err_all_${date}.txt
  stdout_file=$cpwd/stdout_all_${date}.txt
  rm -f $log_file $err_file $stdout_file
 
  refSetup=$def_refSetup
  combination=$def_combination
  nppn=$def_nppn
  numInst=$def_numInst
  if [[ $numInst == "" ]] then ; numInst="1" ; fi #We need a hard default here
  startInst=$def_startInst
  if [[ $startInst == "" ]] then ; startInst="0" ; fi #We need a hard default here
  queue=$def_queue
  wtime=$def_wtime
  px_clm=$def_px_clm
  py_clm=$def_py_cl
  px_cos=$def_px_cos
  py_cos=$def_py_cos
  px_pfl=$def_px_pfl
  py_pfl=$def_py_pfl
  forcingdir_clm=$def_forcingdir_clm
  forcingdir_cos=$def_forcingdir_cos
  forcingdir_oas=$def_forcingdir_oas
  forcingdir_pfl=$def_forcingdir_pfl
  namelist_clm=$def_namelist_clm
  namelist_cos=$def_namelist_cos
  namelist_oas=$def_namelist_oas
  namelist_pfl=$def_namelist_pfl
  startDate=$def_startDate
  runhours=$def_runhours
  restDate=$ref_restDate
}

clearMachineSelection(){
  wtime=""
  queue=""
  clearSetupSelection
}

clearSetupSelection(){
  nppn=""
  px_clm=""
  py_clm=""
  px_cos=""
  py_cos=""
  px_pfl=""
  py_pfl=""
  startDate=""
  restDate=""
  runhours=""

  forcingdir_clm=""
  forcingdir_cos=""
  forcingdir_pfl=""
  forcingdir_oas=""
  clearPathSelection
}

clearPathSelection(){
  rundir=""
  bindir=""
  pfldir=""
  namelist_clm=""
  namelist_cos=""
  namelist_pfl=""
  namelist_oas=""
}

setSelection(){

  if [[ $nppn == "" ]] then ; nppn=$defaultNppn ; fi
  if [[ $wtime == "" ]] then ; wtime=$defaultwtime  ; fi
  if [[ $queue == "" ]] then ; queue=$defaultQ ; fi
  if [[ $px_clm == "" ]] then ; px_clm=$defaultCLMProcX ; fi
  if [[ $py_clm == "" ]] then ; py_clm=$defaultCLMProcY ; fi
  if [[ $px_cos == "" ]] then ; px_cos=$defaultCOSProcX ; fi
  if [[ $py_cos == "" ]] then ; py_cos=$defaultCOSProcY ; fi
  if [[ $px_pfl == "" ]] then ; px_pfl=$defaultPFLProcX ; fi
  if [[ $py_pfl == "" ]] then ; py_pfl=$defaultPFLProcY ; fi
  
  if [[ $forcingdir_clm == "" ]] then ; forcingdir_clm=$defaultFDCLM ; fi
  if [[ $forcingdir_cos == "" ]] then ; forcingdir_cos=$defaultFDCOS ; fi
  if [[ $forcingdir_oas == "" ]] then ; forcingdir_oas=$defaultFDOAS ; fi
  if [[ $forcingdir_pfl == "" ]] then ; forcingdir_pfl=$defaultFDPFL ; fi

  if [[ $namelist_clm == "" ]] then ; namelist_clm=$defaultNLCLM ; fi
  if [[ $namelist_cos == "" ]] then ; namelist_cos=$defaultNLCOS ; fi
  if [[ $namelist_oas == "" ]] then ; namelist_oas=$defaultNLOAS ; fi
  if [[ $namelist_pfl == "" ]] then ; namelist_pfl=$defaultNLPFL ; fi

  if [[ $startDate == "" ]] then ; startDate=$defaultStartDate ; fi
  if [[ $restDate == "" ]] then ; restDate=$defaultRestDate ; fi
  if [[ $runhours == "" ]] then ; runhours=$defaultRunhours ; fi


  if [[ $rundir == "" ]] then
     rundir=$rootdir/run/${platform}_${version}_${combination}_${refSetup}_${date}
  fi

  if [[ $bindir == "" ]] then
     bindir="$rootdir/bin/${platform}_${version}_${combination}"
  fi
  set -A mList ${modelVersion[$version]}
  if [[ $pfldir == "" ]] then ;  pfldir=$rootdir/${mList[3]}_${platform}_${combination} ; fi

}


setCombination(){
  withOAS="false"
  withCOS="false"
  withPFL="false"
  withCLM="false"
  withOASMCT="false"
  withPCLM="false"

  case "$combination" in *clm*) withCLM="true" ;; esac
  case "$combination" in *cos*) withCOS="true" ;; esac
  case "$combination" in *pfl*) withPFL="true" ;; esac
  if [[ $withCLM == "true" && ( $withCOS == "true" || $withPFL == "true" )  ]]; then
    withOAS="true"
    case "$version" in *MCT*) withOASMCT="true" ;; esac
  fi  

}

finalizeSelection(){

  mkdir -p $rundir
  rm -rf $rundir/*

  nproc_oas=0
  nproc_pfl=0
  nproc_clm=0
  nproc_cos=0
  if [[ $withPFL == "true" ]] ; then ; nproc_pfl=$((${px_pfl}*${py_pfl})) ;fi 
  if [[ $withCOS == "true" ]] ; then ; nproc_cos=$((${px_cos}*${py_cos})) ;fi 
  if [[ $withCLM == "true" ]] ; then ; nproc_clm=$((${px_clm}*${py_clm})) ;fi 
  if [[ $withOAS == "true" ]] ; then ; nproc_oas=1 ;fi 
  if [[ $withOASMCT == "true" ]] ; then ; nproc_oas=0 ;fi 


  yyyy=$(date '+%Y' -d "$startDate")
  mm=$(date '+%m' -d "$startDate")
  dd=$(date '+%d' -d "$startDate")
  hh=$(date '+%H' -d "$startDate")

}

terminate(){
 print ""
 print "Terminating $call. No changes were made..."
 rm -f $err_file
 rm -f $log_file
 rm -f $stdout_file
 exit 0
}


check(){
 if [[ $? == 0  ]] then
    print "    ... ${cgreen}passed!${cnormal}"  | tee -a $stdout_file
 else
    print "    ... ${cred}error!!! - aborting...${cnormal}" | tee -a $stdout_file
    print "See $log_file and $err_file" | tee -a $stdout_file
    exit 1
  fi
}

comment(){
  print -n "$1" | tee -a $stdout_file
}

route(){
  print "$1" | tee -a $stdout_file
}

warning(){
  print "Warning!!! - $wmessage"
  print "This could lead to errors or wrong behaviour. Would you like to continue anyway?"
  PS3="Your selection(1-2)?"
  select ret in "yes" "no, exit"
  do  
    if [[ -n $ret ]]; then
       case $ret in
          "yes") break ;;
          "no, exit") terminate ;;
       esac
       break
    fi  
  done
}


hardSanityCheck(){
  if [[ "${versions[${version}]}" == ""  ]] then
      print "The selected version '${version}' is not available. run '.$call --man' for help"
      terminate
  fi

  if [[ "${platforms[${platform}]}" == ""  ]] then
      print "The selected platform '${platform}' is not available. run '.$call --man' for help"
      terminate
  fi

  valid="false"
  if [[ ${refSetup} == "" ]] ; then ; valid="true" ; fi
  case "${setupsAvail[${platform}]}" in *" ${refSetup} "*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; print "This setup is not supported on this machine" ; terminate  ;fi

}

softSanityCheck(){

  #check multi instance functionality (only working with Oasis3-MCT and not on JUQUEEN)
  if [[ $numInst > 1 && $withOAS == "true" && $withOASMCT == "false" ]]; then ; wmessage="The -N option is only supported with Oasis3-MCT. it will be ignored if you continue." ; warning  ;fi
  if [[ $numInst > 1 && $machine == "JUQUEEN" ]] ; then ; wmessage="The -N option is not supported on JUQUEEN. If you continue, the script will setup multiple instances, but the runscript+mapfile won't work." ; warning  ;fi 


  valid="false"
  case "${availability[${platform}]}" in *" ${version} "*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; wmessage="This version is not supported on this machine" ; warning  ;fi 

  valid="false"
  cstr="invalid"
  if [[ $withCLM == "true" &&  $withCOS == "true" && $withPFL == "true"  ]]; then ;cstr=" clm-cos-pfl " ; fi
  if [[ $withCLM == "true" &&  $withCOS == "true" && $withPFL == "false"  ]]; then ;cstr=" clm-cos " ; fi
  if [[ $withCLM == "true" &&  $withCOS == "false" && $withPFL == "true"  ]]; then ;cstr=" clm-pfl " ; fi
  if [[ $withCLM == "true" &&  $withCOS == "false" && $withPFL == "false"  ]]; then ;cstr=" clm " ; fi
  if [[ $withCLM == "false" &&  $withCOS == "true" && $withPFL == "false"  ]]; then ;cstr=" cos " ; fi
  if [[ $withCLM == "false" &&  $withCOS == "false" && $withPFL == "true"  ]]; then ;cstr=" pfl " ; fi
  case "${combinations[${version}]}" in *${cstr}*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; wmessage="This combination is not supported in this version" ; warning  ;fi

}

interactive(){
  clear
  print "${cblue}##############################################${cnormal}"
  print "${cblue}         Interactive installation...          ${cnormal}"
  print "${cblue}##############################################${cnormal}"
  print "The following variables are needed:"
  printState
  print "${cblue}##############################################${cnormal}"
  PS3="Your selection(1-3)?"
  select ret in "!!!start!!!" "edit" "exit"
  do
    if [[ -n $ret ]]; then
       case $ret in
          "!!!start!!!") break ;;
          "edit")
                while true
                do
                  print "Please select a ${cred}number${cnormal} you want to change!"
                  print "Select '0' to go back."
                  read numb
                  if [[ $numb == 0 ]] ; then ; break ; fi
                  if [[ $numb == 1 ]] ; then
                        print "The following options are available:"
                        for a in "${!platforms[@]}" ; do
                                printf "%-20s #%s\n" "$a" "${platforms[$a]}"
                        done
                        print "Please type in your desired value..."
                        read platform
                        comment "  source machine build interface for $platform"
  			  . ${rootdir}/bldsva/machines/${platform}/build_interface_${platform}.ksh >> $log_file 2>> $err_file
      			check
			clearMachineSelection
      			getMachineDefaults
			#reset features if not supported by new machine selection
    			case "${availability[$platform]}" in 
				*" $version "*) ;;
		     		*)
	  			set -A array ${availability[$platform]}
          			version=${array[0]} ;; 
    			esac
    			case "${combinations[$version]}" in 
        			*" $combination "*);;
		         	*)      
          			set -A array ${combinations[$version]}
          			combination=${array[0]} ;;     
    			esac

    			case "${setupsAvail[$platform]}" in 
        			*" $refSetup "*) ;;
		      		*)     
          			set -A array ${setupsAvail[$platform]}
          			refSetup=${array[0]} ;;     
    			esac
      			setCombination
      			comment "  source setup for $refSetup on $platform"
        		  . ${rootdir}/bldsva/setups/$refSetup/${refSetup}_${platform}_setup.ksh >> $log_file 2>> $err_file
      			check
      			initSetup
      			setSelection

                  fi
                  if [[ $numb == 2 ]] ; then
                        print "The following versions are available for $platform:"
                        for a in ${availability[$platform]} ; do
                                printf "%-20s #%s\n" "$a" "${versions[$a]} consisting of: "
                                for b in ${modelVersion[$a]} ; do
                                   printf "%-20s - %s\n" "" "$b"
                                done
                        done
                        print "Please type in your desired value..."
                        read version
                        case "${combinations[$version]}" in  
                                *" $combination "*);;
                                *)    
                                set -A array ${combinations[$version]}
                                combination=${array[0]} ;;    
                        esac
			clearSetupSelection
			setCombination
			comment "  source setup for $refSetup on $platform"
                          . ${rootdir}/bldsva/setups/$refSetup/${refSetup}_${platform}_setup.ksh >> $log_file 2>> $err_file
                        check
			initSetup	
			setSelection

                  fi
                  if [[ $numb == 3 ]] ; then
                        print "The following combinations are available for $version:"
                        for a in ${combinations[$version]} ; do
                                printf "%-20s\n" "$a"
                        done
                        print "Please type in your desired value..."
                        read combination
                        clearSetupSelection
                        setCombination
                        comment "  source setup for $refSetup on $platform"
                          . ${rootdir}/bldsva/setups/$refSetup/${refSetup}_${platform}_setup.ksh >> $log_file 2>> $err_file
                        check
                        initSetup
                        setSelection

                  fi
                  if [[ $numb == 4 ]] ; then 
			print "The following setups are available for $platform:"
                        for a in ${setupsAvail[$platform]} ; do
                                printf "%-20s\n" "$a"
                        done
                        print "Please type in your desired value..."
		        read refSetup
                        clearSetupSelection
                        setCombination
                        comment "  source setup for $refSetup on $platform"
                          . ${rootdir}/bldsva/setups/$refSetup/${refSetup}_${platform}_setup.ksh >> $log_file 2>> $err_file
                        check
                        initSetup
                        setSelection

		  fi


                  if [[ $numb == 5 ]] ; then ; read queue ; fi
                  if [[ $numb == 6 ]] ; then ; read wtime ; fi
                  if [[ $numb == 7 ]] ; then ; read startDate  ; fi
                  if [[ $numb == 8 ]] ; then ; read runhours ; fi
                  if [[ $numb == 9 ]] ; then ; read nppn ; fi
                  if [[ $numb == 10 ]] ; then ; read px_clm ; fi
                  if [[ $numb == 11 ]] ; then ; read py_clm ; fi
                  if [[ $numb == 12 ]] ; then ; read px_cos ; fi
                  if [[ $numb == 13 ]] ; then ; read py_cos ; fi
                  if [[ $numb == 14 ]] ; then ; read px_pfl ; fi
                  if [[ $numb == 15 ]] ; then ; read py_pfl ; fi
                  if [[ $numb == 16 ]] ; then ; read rootdir ;clearPathSelection; setSelection ; fi
                  if [[ $numb == 17 ]] ; then ; read bindir ; fi
                  if [[ $numb == 18 ]] ; then ; read rundir ; fi
                  if [[ $numb == 19 ]] ; then ; read namelist_clm ; fi
                  if [[ $numb == 20 ]] ; then ; read forcingdir_clm ; fi
                  if [[ $numb == 21 ]] ; then ; read namelist_cos ; fi
                  if [[ $numb == 22 ]] ; then ; read forcingdir_cos ; fi
                  if [[ $numb == 23 ]] ; then ; read namelist_pfl ; fi
                  if [[ $numb == 24 ]] ; then ; read forcingdir_pfl ; fi
                  if [[ $numb == 25 ]] ; then ; read namelist_oas ; fi
                  if [[ $numb == 26 ]] ; then ; read forcingdir_oas ; fi
		  if [[ $numb == 27 ]] ; then ; read pfldir ; fi
                  if [[ $numb == 28 ]] ; then ; read profiling ; fi
                  if [[ $numb == 29 ]] ; then ; read numInst ; fi
  		  if [[ $numb == 30 ]] ; then ; read startInst ; fi
                  if [[ $numb == 31 ]] ; then ; read restDate ; fi
                done
                interactive
          ;;
          "exit") terminate ;;
       esac
       break
    fi
  done

}


printState(){
  print ""
  print "${cred}(1)${cnormal} platform (default=$def_platform): ${cgreen}$platform${cnormal}"
  print "${cred}(2)${cnormal} version (default=$def_version): ${cgreen}$version${cnormal}"
  print "${cred}(3)${cnormal} combination (default=$def_combination): ${cgreen}$combination${cnormal}"
  print "${cred}(4)${cnormal} refSetup (default=$def_refSetup): ${cgreen}$refSetup${cnormal}"
  print ""
  print "${cred}(5)${cnormal} scheduler queue (default=$def_queue): ${cgreen}$queue${cnormal}"
  print "${cred}(6)${cnormal} wallclock time (default=$def_wtime): ${cgreen}$wtime${cnormal}"
  print "${cred}(7)${cnormal} startDate (default=$def_startDate): ${cgreen}$startDate${cnormal}"
  print "${cred}(8)${cnormal} run hours (default=$def_runhours): ${cgreen}$runhours${cnormal}"
  print "${cred}(9)${cnormal} number of processors per node (default=$def_nppn): ${cgreen}$nppn${cnormal}"
  print ""
  print "${cred}(10)${cnormal} processors in X for clm (default=$def_px_clm): ${cgreen}$px_clm${cnormal}"
  print "${cred}(11)${cnormal} processors in Y for clm (default=$def_py_clm): ${cgreen}$py_clm${cnormal}"
  print "${cred}(12)${cnormal} processors in X for cos (default=$def_px_cos): ${cgreen}$px_cos${cnormal}"
  print "${cred}(13)${cnormal} processors in Y for cos (default=$def_py_cos): ${cgreen}$py_cos${cnormal}"
  print "${cred}(14)${cnormal} processors in X for pfl (default=$def_px_pfl): ${cgreen}$px_pfl${cnormal}"
  print "${cred}(15)${cnormal} processors in Y for pfl (default=$def_py_pfl): ${cgreen}$py_pfl${cnormal}"
  print ""
  print "${cred}(16)${cnormal} root dir (default=$def_rootdir): ${cgreen}$rootdir${cnormal}"
  print "${cred}(17)${cnormal} bin dir (default=$def_rootdir/bin/${def_platform}_${version}_${combination}): ${cgreen}$bindir${cnormal}"
  print "${cred}(18)${cnormal} run dir (default=$def_rootdir/run/${def_platform}_${version}_${combination}_${refSetup}_${date}): ${cgreen}$rundir${cnormal}"
  print ""
  print "${cred}(19)${cnormal} namelist dir for clm (default='$def_namelist_clm'): ${cgreen}$namelist_clm${cnormal}"
  print "${cred}(20)${cnormal} forcing dir for clm (default='$def_forcingdir_clm'): ${cgreen}$forcingdir_clm${cnormal}"
  print "${cred}(21)${cnormal} namelist dir for cos (default='$def_namelist_cos'): ${cgreen}$namelist_cos${cnormal}"
  print "${cred}(22)${cnormal} forcing dir for cos (default='$def_forcingdir_cos'): ${cgreen}$forcingdir_cos${cnormal}"
  print "${cred}(23)${cnormal} namelist dir for pfl (default='$def_namelist_pfl'): ${cgreen}$namelist_pfl${cnormal}"
  print "${cred}(24)${cnormal} forcing dir for pfl (default='$def_forcingdir_pfl'): ${cgreen}$forcingdir_pfl${cnormal}"
  print "${cred}(25)${cnormal} namelist dir for oas (default='$def_namelist_oas'): ${cgreen}$namelist_oas${cnormal}"
  print "${cred}(26)${cnormal} forcing dir for oas (default='$def_forcingdir_oas'): ${cgreen}$forcingdir_oas${cnormal}"
  print ""
  print "${cred}(27)${cnormal} parflow dir (default=$def_rootdir/${mList[3]}_${def_platform}_$combination): ${cgreen}$pfldir${cnormal}"
  print "${cred}(28)${cnormal} profiling (default=$def_profiling): ${cgreen}$profiling${cnormal}"
  print "${cred}(29)${cnormal} number of TerrSysMP instances (default=$def_numInst): ${cgreen}$numInst${cnormal}"
  print "${cred}(30)${cnormal} counter to start TerrSysMP instances with (default=$def_startInst): ${cgreen}$startInst${cnormal}"
  print "${cred}(31)${cnormal} restart Date (default=$def_restDate): ${cgreen}$restDate${cnormal}"
}


listAvailabilities(){

  print ${cblue}"A list of details for each available platform."${cnormal}
  print ""
  for p in "${!platforms[@]}" ; do
    printf "%-20s #%s\n" "$p" "${platforms[$p]}"
    print ${cgreen}$'\t supported versions:'${cnormal}
    for a in ${availability[$p]} ; do
        print $'\t '"$a"
    done
    print ${cgreen}$'\t supported setups:'${cnormal}
    for a in ${setupsAvail[$p]} ; do
        print $'\t '"$a"
    done
  done


  print ""
  print ${cblue}"A list of details for each version."${cnormal} 
  print ""
  for v in "${!versions[@]}" ; do
    printf "%-20s #%s\n" "$v" "${versions[$v]}"
    print ${cgreen}$'\t possible combinations:'${cnormal}
    print $'\t'${combinations[$v]}              
    print ${cgreen}$'\t componentmodel versions:'${cnormal}     
    for a in ${modelVersion[$v]} ; do
        print $'\t '"$a"
    done
  done
  print ""
  print ${cblue}"A list of details for each setup."${cnormal}
  print ""
  for v in "${!setups[@]}" ; do
    printf "%-20s #%s\n" "$v" "${setups[$v]}"
  done



  exit 0
}

listTutorial(){
  print "1) TODO"
 
  exit 0
}


getRoot(){
  #automatically determine root dir
  call=`echo $0 | sed 's@^\.@@'`                    #clean call from leading dot
  cpwd=`pwd` 
  call=`echo $call | sed 's@^/@@'`                  #clean call from leading /
  call=`echo "/$call" | sed 's@^/\./@/\.\./@'`      #if script is called without leading ./ replace /./ by /../
  curr=`echo $cpwd | sed 's@^/@@'`                   #current directory without leading /    
  call=`echo $call | sed "s@$curr@@"`               #remove current directory from call if absolute path was called
  estdir=`echo "/$curr$call" | sed 's@/bldsva/setup_tsmp.ksh@@'` #remove bldsva/configure machine to get rootpath
}

#######################################
#               Main
#######################################

  cblue=$(tput setaf 4)
  cnormal=$(tput setaf 9)
  cred=$(tput setaf 1)
  cgreen=$(tput setaf 2)

  date=`date +%d%m%y-%H%M%S`
  getRoot 
  getDefaults
  setDefaults

  #GetOpts definition
  USAGE=$'[-?\n@(#)$Id: TerrSysMP setup script 1.0 - '
  USAGE+=$' date: 10.10.2015 $\n]'
  USAGE+="[-author?Fabian Gasper <f.gasper@fz-juelich.de>]"
  USAGE+="[+NAME?TerrSysMP setup script]"
  USAGE+="[+DESCRIPTION?sets up TSMP run by handling namelists and copying necessary files into a run directory]"
  USAGE+="[b:bash?Bash mode - set command line arguments will overwrite default values (no interactive mode) (This is the default with arguments).]"
  USAGE+="[i:interactive?Interactive mode - command line arguments are ignored and defaults will be overwritten during the interactive session (This is the default without arguments).]"
  USAGE+="[a:avail?Prints a listing of every machine with available versions. The script will exit afterwards.]"
  USAGE+="[t:tutorial?Prints a tutorial/description on how to add new versions and platforms to this script. The script will exit afterwards.]"
  USAGE+="[R:rootdir?Absolut path to TerrSysMP root directory.]:[path:='$def_rootdir']"
  USAGE+="[B:bindir?Absolut path to bin directory for the builded executables.]:[path:='$def_bindir']"
  USAGE+="[r:rundir?Absolut path to run directory for TSMP.]:[path:='$def_rundir']"
  USAGE+="[v:version?Tagged TerrSysMP version. Note that not every version might be implemented on every machine. Run option -a, --avail to get a listing.]:[version:='$version']"
  USAGE+="[V:refsetup?Reference setup. This is a setup that is supported and tested on a certain machine. No further inputs are needed for this setup. If you leave it '' the machine default will be taken.]:[refsetup:='$def_refSetup']"
  USAGE+="[m:machine?Target Platform. Run option -a, --avail to get a listing.]:[machine:='$platform']"
  USAGE+="[z:pfldir?Source directory for Parflow. parflow_MACHINE_DATE will be taken if ''.]:[pfldir:='${def_pfldir}']"
  USAGE+="[p:profiling?Makes necessary changes to compile with a profiling tool if available.]:[profiling:='$def_profiling']"
  USAGE+="[c:combination? Combination of component models.]:[combination:='$def_combination']"
  USAGE+="[P:nppn? Number of processors per node. If you leave it '' the machine default will be taken.]:[nppn:='$def_nppn']"
  USAGE+="[N:numinst? Number of instances of TerrSysMP. Currently only works with Oasis3-MCT - ignored otherwise.]:[numinst:='$def_numInst']"
  USAGE+="[n:startinst? Instance counter to start with. Currently only works with Oasis3-MCT - ignored otherwise.]:[startinst:='$def_startInst']"
  USAGE+="[q:queue? Scheduler Queue name. If you leave it '' the machine default will be taken.]:[queue:='$def_queue']"
  USAGE+="[Q:wtime? Wallclocktime for your run. If you leave it '' the machine default will be taken.]:[wtime:='$def_wtime']"
  USAGE+="[s:startdate? Date for your model run. Must be given in the format: 'YYYY-MM-DD HH']:[startdate:='$def_startDate']"
  USAGE+="[S:restdate? Restart date for your model run. Must be given in the format: 'YYYY-MM-DD HH']:[restdate:='$def_restDate']" 
  USAGE+="[T:runhours? Number of simulated hours.]:[runhours:='$def_runhours']" 
  USAGE+="[w:pxclm? Number of tasks for clm in X direction. If you leave it '' the machine default will be taken.]:[pxclm:='$def_px_clm']"
  USAGE+="[W:pyclm? Number of tasks for clm in Y direction. If you leave it '' the machine default will be taken.]:[pyclm:='$def_py_clm']"
  USAGE+="[x:pxcos? Number of tasks for cosmo in X direction. If you leave it '' the machine default will be taken.]:[pxcos:='$def_px_cos']"
  USAGE+="[X:pycos? Number of tasks for cosmo in Y direction. If you leave it '' the machine default will be taken.]:[pycos:='$def_py_cos']"
  USAGE+="[y:pxpfl? Number of tasks for ParFlow in X direction. If you leave it '' the machine default will be taken.]:[pxpfl:='$def_px_pfl']"
  USAGE+="[Y:pypfl? Number of tasks for ParFlow in Y direction. If you leave it '' the machine default will be taken.]:[pypfl:='$def_py_pfl']"
  USAGE+="[d:namoas? Namelist for Oasis. This script will always try to substitute the placeholders by the reference setup values. Make sure your namelist and placeholders are compatible with the reference setup. If you don't wont the substitution remove placeholders from your namelist. This flag will replace the default namelist from the reference setup ]:[namoas:='']"
  USAGE+="[D:forcediroas? Forcing directory for oasis. This will replace the default forcing dir from the reference setup.]:[forcediroas:='']"
  USAGE+="[e:namclm? Namelist for clm. This script will always try to substitute the placeholders by the reference setup values. Make sure your namelist and placeholders are compatible with the reference setup. If you don't wont the substitution remove placeholders from your namelist. This flag will replace the default namelist from the reference setup ]:[namclm:='']"
  USAGE+="[E:forcedirclm? Forcing directory for clm. This will replace the default forcing dir from the reference setup.]:[forcedirclm:='']"
  USAGE+="[f:namcos? Namelist for Cosmo. This script will always try to substitute the placeholders by the reference setup values. Make sure your namelist and placeholders are compatible with the reference setup. If you don't wont the substitution remove placeholders from your namelist. This flag will replace the default namelist from the reference setup ]:[namcos:='']"
  USAGE+="[F:forcedircos? Forcing directory for Cosmo. This will replace the default forcing dir from the reference setup.]:[forcedircos:='']"
  USAGE+="[g:nampfl? Namelist for ParFlow. This script will always try to substitute the placeholders by the reference setup values. Make sure your namelist and placeholders are compatible with the reference setup. If you don't wont the substitution remove placeholders from your namelist. This flag will replace the default namelist from the reference setup ]:[nampfl:='']"
  USAGE+="[G:forcedirpfl? Forcing directory for ParFlow. This will replace the default forcing dir from the reference setup.]:[forcedirpfl:='']"

  USAGE+=$'\n\n\n\n'


  mode=0
  args=0
  # parsing the command line arguments
  while getopts "$USAGE" optchar ; do
    case $optchar in
    i)  mode=2 ;;
    b)  mode=1 ;;
    m)  platform="$OPTARG" ; args=1 ;; 
    p)  profling="${OPTARG}" ; args=1 ;;
    v)  version="$OPTARG"  ;  args=1 ;;
    V)  refSetup="$OPTARG"  ;  args=1 ;; 
    a)  listA="true" ;;
    t)  listTutorial ;;
    q)  queue=$OPTARG ; args=1 ;; 
    Q)  wtime=$OPTARG ; args=1 ;;   
    P)  nppn=$OPTARG ; args=1 ;;
    n)  startInst=$OPTARG ; args=1 ;;
    N)  numInst=$OPTARG ; args=1 ;;
    s)  startDate=$OPTARG ; args=1 ;;
    S)  restDate=$OPTARG ; args=1 ;;
    T)  runhours=$OPTARG ; args=1 ;;    
    
    d)  namelist_oas=$OPTARG ; args=1 ;;
    D)  forcingdir_oas=$OPTARG ; args=1 ;;
    e)  namelist_clm=$OPTARG ; args=1 ;;
    E)  forcingdir_clm=$OPTARG ; args=1 ;;
    f)  namelist_cos=$OPTARG ; args=1 ;;
    F)  forcingdir_cos=$OPTARG ; args=1 ;;
    g)  namelist_pfl=$OPTARG ; args=1 ;;
    G)  forcingdir_pfl=$OPTARG ; args=1 ;;

    w)  px_clm=$OPTARG ; args=1 ;;
    W)  py_clm=$OPTARG ; args=1 ;;
    x)  px_cos=$OPTARG ; args=1 ;;
    X)  py_cos=$OPTARG ; args=1 ;;
    y)  px_pfl=$OPTARG ; args=1 ;;
    Y)  py_pfl=$OPTARG ; args=1 ;;
 
    R)  rootdir="$OPTARG" ; args=1 ;;
    B)  bindir="$OPTARG" ; args=1 ;;
    r)  rundir="$OPTARG" ; args=1 ;;
    c)  combination="$OPTARG" ; args=1 ;;
    z)  pfldir="$OPTARG"; args=1 ;;
    esac
  done





comment "  source list with supported machines and configurations"
  . $rootdir/bldsva/supported_versions.ksh
check

  if [[ $listA == "true" ]] ; then ; listAvailabilities ; fi

  hardSanityCheck

  #if no combination is set, load first as default
  if [[ $combination == "" ]] ; then
    set -A array ${combinations[$version]}
    combination=${array[0]}
  fi
  if [[ $refSetup == "" ]] ; then
    set -A array ${setupsAvail[$platform]}
    refSetup=${array[0]}
  fi

  comment "  source setup for $refSetup on $platform"
    . ${rootdir}/bldsva/setups/$refSetup/${refSetup}_${platform}_setup.ksh >> $log_file 2>> $err_file
  check

  setCombination
  initSetup
  comment "  source machine build interface for $platform"
    . ${rootdir}/bldsva/machines/${platform}/build_interface_${platform}.ksh >> $log_file 2>> $err_file
  check
  getMachineDefaults
  setSelection
     	


  # determine whether or not to run interactive session
  if [[ $mode == 0 ]] then
    if [[ $args == 0 ]] then
        mode=2
    else
        mode=1
    fi
  fi
  if [[ $mode == 2 ]] then ; interactive ; fi


  softSanityCheck
  finalizeMachine
  finalizeSelection 

#  start setup
origrundir=$rundir
orignamelist_cos=$namelist_cos
orignamelist_clm=$namelist_clm
orignamelist_pfl=$namelist_pfl
for instance in {$startInst..$(($startInst+$numInst-1))}
do
route ${cblue}"> creating instance: $instance"${cnormal}
if [[ $numInst > 1 && ( $withOASMCT == "true" || $withOAS == "false"   ) ]] ; then 
rundir=$origrundir/tsmp_instance_$instance
comment "  mkdir sub-directory for instance"
  mkdir -p $rundir >> $log_file 2>> $err_file
check
  if [[ -e "${orignamelist_cos}_${instance}" ]] ; then 
	namelist_cos="${orignamelist_cos}_${instance}"
  else
        namelist_cos="$orignamelist_cos"	
  fi
  if [[ -e "${orignamelist_clm}_${instance}" ]] ; then
        namelist_clm="${orignamelist_clm}_${instance}"
  else
        namelist_clm="$orignamelist_clm"
  fi
  if [[ -e "${orignamelist_pfl}_${instance}" ]] ; then
        namelist_pfl="${orignamelist_pfl}_${instance}"
  else
        namelist_pfl="$orignamelist_pfl"
  fi
fi

  if [[ $withCLM == "true" ]] ; then 
comment "  source clm build interface for $platform"
      . ${rootdir}/bldsva/intf_oas3/${mList[1]}/arch/${platform}/build_interface_${mList[1]}_${platform}.ksh  >> $log_file 2>> $err_file
check
      setup_clm
comment "  cp clm exe to $origrundir" 
    cp $bindir/clm $origrundir >> $log_file 2>> $err_file
check
  fi
  if [[ $withCOS == "true" ]] ; then
comment "  source cos build interface for $platform"
      . ${rootdir}/bldsva/intf_oas3/${mList[2]}/arch/${platform}/build_interface_${mList[2]}_${platform}.ksh  >> $log_file 2>> $err_file
check
      setup_cos 
comment "  cp cos exe and starter to $origrundir"
    cp $bindir/lmparbin_pur $origrundir  >> $log_file 2>> $err_file
check
  fi
  if [[ $withPFL == "true" ]] ; then 
comment "  source pfl build interface for $platform"
      . ${rootdir}/bldsva/intf_oas3/${mList[3]}/arch/${platform}/build_interface_${mList[3]}_${platform}.ksh  >> $log_file 2>> $err_file
check
      setup_pfl 
comment "  cp pfl exe to $origrundir"
    cp $bindir/parflow $origrundir  >> $log_file 2>> $err_file
check
  fi
  if [[ $withOAS == "true" ]] ; then 
comment "  source oas build interface for $platform"
      . ${rootdir}/bldsva/intf_oas3/${mList[0]}/arch/${platform}/build_interface_${mList[0]}_${platform}.ksh  >> $log_file 2>> $err_file
check
      setup_oas 
    if [[ $withOASMCT == "false" ]] ; then 
comment "  cp oas exe to $origrundir"
	 cp $bindir/oasis3.MPI1.x $origrundir  >> $log_file 2>> $err_file
check
    fi
  fi

  finalizeSetup
route ${cblue}"< creating instance: $instance"${cnormal}
done
  rundir=$origrundir
  namelist_cos="$orignamelist_cos"
  namelist_clm="$orignamelist_clm"
  namelist_pfl="$orignamelist_pfl"

  createRunscript

  printState >> $log_file
  print "$call $*">> $log_file
  #remove special charecters for coloring from logfiles
  sed -i "s,.\[32m,,g" $log_file
  sed -i "s,.\[39m,,g" $log_file
  sed -i "s,.\[31m,,g" $log_file
  sed -i "s,.\[34m,,g" $log_file
  sed -i "s,.\[91m,,g" $log_file

  sed -i "s,.\[32m,,g" $stdout_file
  sed -i "s,.\[39m,,g" $stdout_file
  sed -i "s,.\[31m,,g" $stdout_file
  sed -i "s,.\[34m,,g" $stdout_file
  sed -i "s,.\[91m,,g" $stdout_file

  mv -f $err_file $rundir
  mv -f $log_file $rundir
  mv -f $stdout_file $rundir

  print ${cgreen}"install script finished sucessfully"${cnormal}
  print "Rootdir: ${rootdir}"
  print "Bindir: ${bindir}"
  print "Rundir: ${rundir}"

