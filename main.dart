import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TabBarDemo());
}

class Materia {
  String nombre = "";
  int parciales = 0;
  int color = 0; //100-900

  Materia(String nom, int p, int c){
    this.nombre = nom;
    this.parciales = p;
    this.color = c;
  }
}

//Prueba para materias,
List<Materia> listaMaterias = [
  Materia("Materia 1",3,100),
  Materia("Materia 2",4,200),
  Materia("Materia 3",3,300),
  Materia("Materia 4",4,400),
  Materia("Materia 5",3,500),
  Materia("Materia 6",5,600),
  Materia("Materia 7",3,700),
  Materia("Materia 8",2,800),
];

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)), //Asignaturas
                Tab(icon: Icon(Icons.event)), //Eventos
                Tab(icon: Icon(Icons.accessibility)), //Profesores
                Tab(icon: Icon(Icons.fact_check)), //Calificaciones
              ],
            ),
            title: const Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: <Widget>[
              const Icon(Icons.home), //Asignaturas
              const Icon(Icons.event), //Eventos
              const Icon(Icons.accessibility), //Profesores
              getMaterias(), //Calificaciones
            ],
          ),
        ),
      ),
    );
  }

  //método para mostrar las materias
  Container getMaterias() {
    return Container(
      child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: listaMaterias.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InformacionMateria(materia : listaMaterias[index])),
              );
            }, 
              child: Container(
                height: 40,
                color: Colors.red[listaMaterias[index].color],
                child: Center(child: Text(listaMaterias[index].nombre)),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            color: Colors.white,
          ),
      ),
    );
  }

}

class InformacionMateria extends StatefulWidget {
   const InformacionMateria({Key? key, required this.materia}) : super(key: key);

  final Materia materia;

  @override
  State<InformacionMateria> createState() => _InformacionMateria();

}

class _InformacionMateria extends State<InformacionMateria> {

  final myController = TextEditingController();
  String _dropdownValue = "Parcial 1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materia.nombre),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            getCalificaciones(widget.materia.parciales),
            Container(
              height: 50,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  ListTile(
                    title: Text('Ordinario: 8.0'),
                  ),
                ]
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Guardar calificación"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        DropdownButtonFormField<String>(
                          value: _dropdownValue,
                          items: getParciales(widget.materia.parciales).map((String value) {
                            return new DropdownMenuItem<String>(
                              child: new Text(value),
                              value: value,
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(()  => _dropdownValue = newValue!);
                          },
                          onSaved: (String? newValue) {
                            setState(()  => _dropdownValue = newValue!);
                          },
                        ),
                        TextField(
                          controller: myController,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancelar'),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Guardar'),
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              }
          );
        },
        child: const Icon(Icons.add),
      )
    );
  }

  //Calificaciones
  Container getCalificaciones(int parciales) {

    return Container(
      height: 55 * parciales.toDouble(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: parciales,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text('Parcial ${index+1}: 8.0'),
          );
        },
      ),
    );
  }

  List<String> getParciales(int parciales){
    return List.generate(
        parciales,
        (index) => 'Parcial ${index+1}',
    );
  }
}
