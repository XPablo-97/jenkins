import { Component } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Pokemon } from './models/pokemon.model';
import { Response } from './models/response.model';

import { environment } from 'src/environments/environment';

//import { ConfigService } from '../app/services/configservice.service'; // Importa el servicio de configuración

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  pokemonName: string = ""; //"pikachu" "clefairy" "charmander"
  email: string = "";
  pokemonData: Pokemon = {}; // Variable con la interfaz
  savedPokemons: any[]; // Arreglo para almacenar los registros guardados
  dominantColor = '#1E90FF';
  apiNode: string = environment.apiNode // API de Node
  apiNet: string = environment.apiNet // API de .NET

  constructor(private http: HttpClient) {
    this.savedPokemons = [];
  }

  ngOnInit() {
  }

  async getPokemonData(): Promise<void> {
    const url = `https://pokeapi.co/api/v2/pokemon/${this.pokemonName.toLowerCase()}`;

    try {
      let response = await this.http.get<any>(url).toPromise();
            
      this.pokemonData = {
        name: response.name,
        weight: response.weight,
        height: response.height,
        spriteUrl: response.sprites.front_default,
        type: response.types[0].type.name
      }      
      this.setDominantColor(response.types[0].type.name);
      //console.log('Datos del Pokémon:', this.pokemonData);
    } catch (error) {
      if(error instanceof HttpErrorResponse){
        if (error.status === 404) {
          alert('El Pokémon no fue encontrado.');
        } else {
          alert('Error en la API: ' + error.status);
        }
      }
      else {
        alert('Error inesperado: ' + error);
      }
    }
  }

  async savePokemon() {
    const url = `${this.apiNode}pokemon`; 

    try {
      const response = await this.http.post<Response>(url, this.pokemonData).toPromise();
      if(response?.ok){
        alert('Pokemon guardado con éxito: ' + response?.result._id);
        console.log('Pokemon guardado con éxito: ', response?.result._id);
        //this.getSavedPokemons();
      } else{
        alert('No se pudieron guardar los datos del pokemon');
        console.log('No se pudieron guardar los datos del pokemon');
      }      
    } catch (error) {
      console.error('Error al guardar el Pokemon:', error);
    }
  }

  // Método para obtener los registros guardados
  getSavedPokemons(): void {
    const url = `${this.apiNode}pokemon`; 

    this.http.get(url).subscribe({
      next: (response:any) => {
        if(response.ok){
          this.savedPokemons = response.result;
          console.log('Registros guardados:', response);
        } else{
          this.savedPokemons = [];
        }
      },
      error: (error) => {
        console.error('Error al obtener los registros:', error);
        alert('No se pudieron obtener los registros. Intenta de nuevo más tarde.');
      },
    });
  }

  deletePokemon(id:string) {
    const url = `${this.apiNode}pokemon/${id}`; 

    this.http.delete(url).subscribe({
      next: (response:any) => {
        if(response.ok){
          alert(response.result);
          console.log('Registro eliminado', response.result);
          //this.getSavedPokemons();
        } else{
          alert("El pokemon no fue eliminado");
          console.log('El pokemon no fue eliminado', response.result);
        }
      },
      error: (error) => {
        console.error('Error al borrar el pokemon:', error);
        alert('No se pudo eliminar el pokemon');
      },
    });
  }

  compartirPorEmail() {
    const url = `${this.apiNet}email/enviar-email`; 
    let datos = {
      toEmail: this.email,
      subject: "Blockstellart",
      body: "Mi lista de pokemon: " + JSON.stringify(this.savedPokemons)
    }

    this.http.post<Response>(url, datos).subscribe({
      next: (response:any) => {
        if(response.ok){
          console.log(response);
          alert(response.result);
        } else{
          console.log(response);
          alert(response.result);
        }
      },
      error: (error) => {
        console.error('Error:', error);
      },
    });
  }

  validarEmail() {
    const url = `${this.apiNet}email/verificar-email`; 
    let emailValidar = {
      "verificarEmail": this.email
    }

    this.http.post<Response>(url, emailValidar).subscribe({
      next: (response:any) => {
        if(response.ok){
          console.log(response);
          alert(response.result);
        } else{
          console.log(response);
          alert(response.result);
        }
      },
      error: (error) => {
        console.error('Error en validación:', error);
      },
    });
  }


  setDominantColor(type: string) {
    const typeColors: { [key: string]: string } = {
      fire: '#FF4422',
      water: '#1E90FF',
      grass: '#7AC74C',
      electric: '#F7D02C',
      psychic: '#F95587',
      ice: '#96D9D6',
      dragon: '#6F35FC',
      dark: '#705746',
      fairy: '#D685AD',
    };

    this.dominantColor = typeColors[type.toLowerCase()] || '#A8A77A'; // Color predeterminado
  }
}
