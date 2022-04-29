import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            title: 'Agenda Escolar',
            home: MyHomePage(),
        );
    }
}

class subjectInfo {
  late String name, start, end;
  late Color color;

  subjectInfo(String _name, String _start, String _end, Color _color) {
    name = _name;
    start = _start;
    end = _end;
    color = _color;
  }

  void setStates(String _name, String _start, String _end, Color _color) {
    name = _name;
    start = _start;
    end = _end;
    color = _color;
  }

  @override
  String toString() {
    return "nombre: $name inicio: $start fin: $end color: $color ";
  }
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

class MyHomePage extends StatefulWidget {
    const MyHomePage({Key? key}) : super(key: key);
    
    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    List<subjectInfo> subjects = [];

    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.dashboard_outlined)),
                Tab(icon: Icon(Icons.event_outlined)),
                Tab(icon: Icon(Icons.accessibility_new_outlined)),
                Tab(icon: Icon(Icons.assessment_outlined,)),
              ],
            ),
            title: const Text('Agenda Escolar'),
          ),
          body: TabBarView(
            children: <Widget>[
              MySubjectPage(),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
              getMaterias(),
            ],
          ),
          ),
        );
    }

    Widget MySubjectPage() {
      return Scaffold(
        body: ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: subjects[index].color,
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                        subjects[index].name,
                        style: const TextStyle(fontSize: 30)
                    ),
                    subtitle: Text(
                        subjects[index].start + " - " + subjects[index].end,
                        style: const TextStyle(height: 2, fontSize: 15),
                    ),
                    leading: const Icon(Icons.subject),
                  ),
                  Container(
                      margin: const EdgeInsets.only(right: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(onPressed: () => {
                            setState(() {
                              subjects.removeAt(index);
                            }),
                          }, child: const Text('Eliminar')),
                        ],
                      )
                  )
                ],
              ),
            );
          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => MyNewSubject(),
          child: const Icon(Icons.add),
        ),
      );
    }

    Widget getMaterias() {
        return Scaffold(
            body: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: listaMaterias.length,
                itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InformacionMateria(materia : listaMaterias[index])),
                            );
                        }, 
                        child: SizedBox(
                            height: 50,
                            child: Card(
                                elevation: 6,
                                color: Colors.red[listaMaterias[index].color],    
                                child: Center(child: Text(listaMaterias[index].nombre)),
                            ),
                        ),
                    );
                },
                separatorBuilder: (context, index) => const Divider(
                    color: Colors.white,
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                   addMateria(); 
                },
                child: const Icon(Icons.add),
            ),
        );
    }

    void addMateria() {
        String _mat = "";
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text("Agrega Materia"),
                content: SingleChildScrollView(
                    child: Center(
                        child: Column(
                            children: <Widget>[
                                TextFormField(
                                    decoration: const InputDecoration(
                                        icon: Icon(Icons.chevron_right),
                                        labelText: 'Nombre',
                                    ),
                                    onChanged: (String? value) {
                                        _mat = value.toString();
                                    }
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    void MyNewSubject() {
        double height = MediaQuery.of(context).size.width;
        double alturaColors = height * 0.6;
        double circleRad = height * 0.06;
        Color colorC = Colors.white;
        String _name = "", _start = "", _end = "";
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text("Crear Materia"),
                content: SingleChildScrollView(
                    child: Center(
                        child: Column(
                            children: <Widget>[
                                Container(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                        children: <Widget>[
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    icon: Icon(Icons.chevron_right),
                                                    labelText: 'Materia *',
                                                ),
                                                onChanged: (String? value) {
                                                    _name = value.toString();
                                                }
                                            ),
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    icon: Icon(Icons.schedule),
                                                    labelText: 'Hora de inicio * (00:00 am/pm)',
                                                ),
                                                onChanged: (String? value) {
                                                    _start = value.toString();
                                                }
                                            ),
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    icon: Icon(Icons.schedule),
                                                    labelText: 'Hora de fin * (00:00 am/pm)',
                                                ),
                                                onChanged: (String? value) {
                                                    _end = value.toString();
                                                }
                                            ),
                                        ],
                                    ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    height: alturaColors,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children:  <Widget>[
                                                        CircleAvatar(
                                                            backgroundColor: Colors.tealAccent[100],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.tealAccent[100]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.tealAccent[700],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.tealAccent[700]!;
                                                                }
                                                            ),
                                                        ), 
                                                        CircleAvatar(
                                                            backgroundColor: Colors.pink[50],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.pink[50]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.pink[300],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.pink[300]!;
                                                                }
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                        CircleAvatar(
                                                            backgroundColor: Colors.amber[300],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.amber[300]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.amber[700],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.amber[700]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.blueGrey[100],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.blueGrey[100]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(   
                                                            backgroundColor: Colors.blueGrey,
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.blueGrey;
                                                                }
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                    CircleAvatar(
                                                        backgroundColor: Colors.lime[300],
                                                        radius: circleRad, //Text
                                                            child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.lime[300]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.lime[700],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.lime[700]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.brown[100],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.brown[100]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.brown[400],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.brown[400]!;
                                                            }
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                        child: const Text('Cancelar'),
                    ),
                    TextButton(
                        onPressed: (() {
                            setState(() {
                                subjects.add(subjectInfo(_name, _start, _end, colorC));
                            }
                            );
                            Navigator.pop(context, 'Guardar');
                        }),
                        child: const Text('Guardar'),
                    ),
                ],
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
                  title: const Text("Guardar calificación"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        DropdownButtonFormField<String>(
                          value: _dropdownValue,
                          items: getParciales(widget.materia.parciales).map((String value) {
                            return DropdownMenuItem<String>(
                              child: Text(value),
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
