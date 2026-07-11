import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

fetch('/assets/config.json')
  .then((response) => response.json())
  .then((config) => {
    // Inserta las variables de entorno dinámicas en el objeto `environment`
    environment.apiNode = config.apiNode || environment.apiNode;
    environment.apiNet = config.apiNet || environment.apiNet;
    
    // Inicia la aplicación Angular
    platformBrowserDynamic().bootstrapModule(AppModule)
      .catch(err => console.error(err));
  })
  .catch((error) => {
    console.error('Error al cargar config.json:', error);
    console.warn('Se usarán las variables predeterminadas del environment');
    // Si ocurre un error, aún inicia la aplicación con los valores predeterminados
    platformBrowserDynamic()
      .bootstrapModule(AppModule)
      .catch((err) => console.error(err));
  });

/* platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
 */