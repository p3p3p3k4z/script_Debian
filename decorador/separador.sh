#! /bin/bash

source ./decorador/pintor.sh

function divisor()    { imprimir_color "$1" "\t********************************************************"; }
function divisor2()   { imprimir_color "$1" "\t--------------------------------------------------------"; }
function div_hash()   { imprimir_color "$1" "\t########################################################"; }
function div_dots()   { imprimir_color "$1" "\t........................................................"; }
function div_wave()   { imprimir_color "$1" "\t~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~="; }
function div_tech()   { imprimir_color "$1" "\t</> </> </> </> </> </> </> </> </> </> </> </> </> </>"; }
function div_arrows() { imprimir_color "$1" "\t>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"; }
function div_slash()  { imprimir_color "$1" "\t////////////////////////////////////////////////////////"; }
function div_hex()    { imprimir_color "$1" "\t01010101010101010101010101010101010101010101010101010101"; }
