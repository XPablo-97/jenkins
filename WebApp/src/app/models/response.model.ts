import { Pokemon } from "./pokemon.model";

export interface Response {
    ok?: boolean;
    result: Pokemon;
}