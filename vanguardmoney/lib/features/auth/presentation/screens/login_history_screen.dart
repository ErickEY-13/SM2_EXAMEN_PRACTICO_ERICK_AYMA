import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../providers/login_history_provider.dart';
import '../widgets/login_stats_card.dart';
import '../widgets/login_history_card.dart';
import '../widgets/date_range_filter.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/login_history.dart';

class LoginHistoryScreen extends ConsumerStatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  ConsumerState<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends ConsumerState<LoginHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final loginHistoryAsync = ref.watch(loginHistoryStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de inicios de sesión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: loginHistoryAsync.when(
        data: (loginHistory) {
          if (loginHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay registros de inicio de sesión'),
                ],
              ),
            );
          }

          // Filtrar por fecha si hay un rango seleccionado
          var filteredHistory = loginHistory;
          if (_startDate != null || _endDate != null) {
            filteredHistory = loginHistory.where((login) {
              if (_startDate != null && login.timestamp.isBefore(_startDate!)) {
                return false;
              }
              if (_endDate != null &&
                  login.timestamp.isAfter(_endDate!.add(const Duration(days: 1)))) {
                return false;
              }
              return true;
            }).toList();
          }

          // Ordenar por fecha más reciente primero
          filteredHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    DateRangeFilter(
                      startDate: _startDate,
                      endDate: _endDate,
                      onChanged: (dateRange) {
                        setState(() {
                          _startDate = dateRange?.start;
                          _endDate = dateRange?.end;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LoginStatsCard(
                        loginHistory: filteredHistory,
                        title: 'Inicios de sesión por día',
                        startColor: Theme.of(context).colorScheme.primary,
                        endColor:
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final login = filteredHistory[index];
                    return LoginHistoryCard(
                      login: login,
                      isFirst: index == 0,
                      onTap: () => _showLoginDetails(context, login),
                    );
                  },
                  childCount: filteredHistory.length,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  void _showLoginDetails(BuildContext context, LoginHistory login) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.25,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Detalles del inicio de sesión',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _DetailItem(
                icon: Icons.email,
                title: 'Email',
                value: login.email,
              ),
              const SizedBox(height: 8),
              _DetailItem(
                icon: Icons.access_time,
                title: 'Fecha y hora',
                value: login.timestamp.toString(),
              ),
              const SizedBox(height: 8),
              _DetailItem(
                icon: Icons.language,
                title: 'Dirección IP',
                value: login.ipAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
