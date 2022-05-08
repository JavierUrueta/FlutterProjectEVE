import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp().then((value) {
        runApp(const MyApp());
    });
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

class SubjectInfo {
    late int id;
    late String name, start, end;
    late Color color;
    late List<double> ratings = [];

    SubjectInfo(int _id, String _name, String _start, String _end, Color _color) {
        id = _id;
        name = _name;
        start = _start;
        end = _end;
        color = _color;
    }

    setRating(double _rating) {
        ratings.add(_rating);
    }

    @override
    String toString() {
        return "nombre: $name inicio: $start fin: $end color: $color ";
    }

    String hashMapRatings() {
        String map = "";
        for (int i = 0; i < ratings.length; i++) {
          if (i != ratings.length - 1) {
            map += '${i+1}:${ratings[i]}, ';
          }else{
            map += '${i+1}:${ratings[i]}';
          }
        }
        return map;
    }

    HashMap<String, String> createDataforDatabase() {
        final baseMap = <String, String>{'id': id.toString(), 'nombre': name, 'horaInicio': start, 'horaFin': end, 
                                          'color': color.toString(), 'ratings': hashMapRatings()};
        final mapOf = HashMap<String, String>.of(baseMap);
        return mapOf;
    }
}

class ProfesorInfo {
    late int id;
    late String name, email, mate;
    late Color color;

    ProfesorInfo(int _id, String _name, String _email, String _mate, Color _color) {
        id = _id;
        name = _name;
        email = _email;
        mate = _mate;
        color = _color;
    }

    @override
    String toString() {
        return "nombre: $name Correo: $email materia: $mate color: $color ";
    }

    HashMap<String, String> createDataforDatabase() {
        final baseMap = <String, String>{'nombre': name, 'email': email, 'materia': mate, 'color': color.toString()};
        final mapOf = HashMap<String, String>.of(baseMap);
        return mapOf;
    }
}

class EventInfo {
    late int id;
    late String name, mate, dia, mes, anio;
    late Color color;

    EventInfo(int _id, String _name, String _mate, String _dia, String _mes, String _anio, Color _color) {
        id = _id;
        name = _name;
        mate = _mate;
        dia = _dia;
        mes = _mes;
        anio = _anio;
        color = _color;
    }

    @override
    String toString() {
        return "nombre: $name materia: $mate fecha: $dia / $mes / $anio color: $color ";
    }

    HashMap<String, String> createDataforDatabase() {
        final baseMap = <String, String>{'nombre': name, 'materia': mate, 'dia': dia, 
                                         'mes': mes, 'anio': anio, 'color': color.toString()};
        final mapOf = HashMap<String, String>.of(baseMap);
        return mapOf;
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

    List<SubjectInfo> subjects = [];
    List<EventInfo> events = [];
    List<ProfesorInfo> teachers = [];
    final db  = FirebaseFirestore.instance;
    
    @override
    Widget build(BuildContext context) {
      initializeListsSubjects();
      initializeListsEvents();
      initializeListsProfesors();
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
                        EventPage(),
                        ProfesorPage(),
                        getMaterias(),
                    ],
                ),
            ),
        );
    }
    
    initializeListsSubjects() async{
      List<SubjectInfo> sjct = [];

      await db.collection('Asignaturas').get().then((value) {
        value.docs.forEach((element) {  
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          final s = SubjectInfo(int.parse(element.data()['id']), element.data()['nombre'], 
                                element.data()['horaInicio'], element.data()['horaFin'], color);
          sjct.add(s);
        });
      });

      setState(() {
        subjects = sjct;
      });
    }

    initializeListsEvents() async{
      List<EventInfo> event = [];

      await db.collection('Eventos').get().then((value) {
        value.docs.forEach((element) {  
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          final e = EventInfo(int.parse(element.data()['id']), element.data()['nombre'], element.data()['materia'], 
                              element.data()['dia'], element.data()['mes'], element.data()['anio'], color);
          event.add(e);
        });
      });

      setState(() {
        events = event;
      });
    }

    initializeListsProfesors() async{
      List<ProfesorInfo> prof = [];

      await db.collection('Profesores').get().then((value) {
        value.docs.forEach((element) {  
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          final p = ProfesorInfo(int.parse(element.data()['id']), element.data()['nombre'], element.data()['email'], element.data()['materia'] ,color);
          prof.add(p);
        });
      });

      setState(() {
        teachers = prof;
      });
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
                            db.collection('Asignaturas').doc(subjects[index].id.toString()).delete(),
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
        return ListView.separated(
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
            );
    }

    void MyNewSubject() {
        double height = MediaQuery.of(context).size.width;
        double alturaColors = height * 0.6;
        double circleRad = height * 0.06;
        Color colorC = Colors.white;
        String _name = "", _start = "", _end = "";
        bool result = false;
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
                        onPressed: () {
                            if(_name.isNotEmpty && _start.isNotEmpty && _end.isNotEmpty) {
                              final s = SubjectInfo(subjects.length + 1,_name, _start, _end, colorC);
                              db.collection("Asignaturas").doc(s.id.toString()).set(s.createDataforDatabase());
                            }
                            Navigator.pop(context, 'Guardar');
                        },
                        child: const Text('Guardar'),
                    ),
                ],
            ),
        );
    }

    void NewProfessor() {
    double height = MediaQuery.of(context).size.width;
    double alturaColors = height * 0.6;
    double circleRad = height * 0.06;
    Color colorC = Colors.white;
    String _name = "", _email = "", _mate = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Profesor"),
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
                            icon: Icon(Icons.person_outline),
                            labelText: 'Nombre del profesor',
                          ),
                          onChanged: (String? value) {
                            _name = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: 'Correo',
                          ),
                          onChanged: (String? value) {
                            _email = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.book),
                            labelText: 'Materia',
                          ),
                          onChanged: (String? value) {
                            _mate = value.toString();
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
                if (_name != "" && _email != "" && _mate != "") {
                  final p = ProfesorInfo(teachers.length + 1, _name, _email, _mate, colorC);
                  db.collection("Profesores").doc(p.id.toString()).set(p.createDataforDatabase());
                }
                Navigator.pop(context, 'Guardar');
            }),
              child: const Text('Guardar'),
            ),
        ],
      ),
    );
  }

  Widget ProfesorPage() {
        return Scaffold(
        body: ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (BuildContext context, int index) {
                return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: teachers[index].color,
                    margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
                    elevation: 10,
                    child: Column(
                        children: <Widget>[
                            ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                                title: Text(
                                    teachers[index].name,
                                    style: const TextStyle(fontSize: 30)
                                ),
                                subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                        children: <Widget>[
                          Text(teachers[index].mate ,
                            style: const TextStyle(height: 1.5, fontSize: 15),),

                          Text(teachers[index].email,
                            style: const TextStyle(height:1.5, fontSize: 15),),
                        ])
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
                              teachers.removeAt(index);
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
        onPressed: () => NewProfessor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget EventPage() {
    return Scaffold(
      body: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: events[index].color,
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                        events[index].name,
                        style: const TextStyle(fontSize: 30)
                    ),
                    subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                            children: <Widget>[
                              Text(events[index].mate ,
                                style: const TextStyle(height: 2, fontSize: 15),),

                              Text(events[index].dia + "/"+ events[index].mes + "/"+ events[index].anio,
                                style: const TextStyle(height:1.5, fontSize: 15),),

                            ])
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
                              events.removeAt(index);
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
        onPressed: () => NewEvent(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void NewEvent() {
    double height = MediaQuery.of(context).size.width;
    double alturaColors = height *.2;
    double circleRad = height * 0.06;
    Color colorC = Colors.white;
    String _name = "", _mate = "", _dia = "", _mes = "", _anio = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Evento"),
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
                            icon: Icon(Icons.event),
                            labelText: 'Nombre del Evento',
                          ),
                          onChanged: (String? value) {
                            _name = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.book),
                            labelText: 'Materia',
                          ),
                          onChanged: (String? value) {
                            _mate = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Dia',
                          ),
                          onChanged: (String? value) {
                            _dia = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Mes',
                          ),
                          onChanged: (String? value) {
                            _mes = value.toString();
                          }
                      ),TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Año',
                          ),
                          onChanged: (String? value) {
                            _anio = value.toString();
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
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.red;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.yellow;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.green;
                                }
                            ),
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
              if(_name != "" && _mate != "" && _dia != "" && _mes != "" && _anio != ""){
                final e = EventInfo(events.length + 1, _name, _mate, _dia, _mes, _anio, colorC);
                db.collection("Eventos").doc(e.id.toString()).set(e.createDataforDatabase());
              }
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
