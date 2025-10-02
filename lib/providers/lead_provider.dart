import 'package:flutter/material.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/repositories/lead_repository.dart';

class LeadProvider with ChangeNotifier {
  final LeadRepository _leadRepository;
  String? _currentUserId; // Add current user ID

  List<Lead> _leads = [];
  bool _isLoading = false;
  String _errorMessage = '';

  LeadProvider(this._leadRepository);

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get totalLeads => _leads.length;
  int get convertedLeads => _leads
      .where((lead) => lead.status == 'Converted' || lead.status == 'Won')
      .length;
  int get pendingLeads => _leads
      .where((lead) => lead.status == 'New' || lead.status == 'Contacted')
      .length;
  int get lostLeads => _leads.where((lead) => lead.status == 'Lost').length;

  // New getters for specific lead statuses
  int get proposalLeads =>
      _leads.where((lead) => lead.status == 'Proposal').length;
  int get contactedLeads =>
      _leads.where((lead) => lead.status == 'Contacted').length;
  int get qualifiedLeads =>
      _leads.where((lead) => lead.status == 'Qualified').length;
  int get newLeads => _leads.where((lead) => lead.status == 'New').length;
  int get wonLeads => _leads.where((lead) => lead.status == 'Won').length;

  // Set current user ID
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<void> loadLeads() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_currentUserId != null) {
        // Load leads for the current user only
        _leads = await _leadRepository.getLeadsByUserId(_currentUserId!);
      } else {
        // Load all leads if no user is set
        _leads = await _leadRepository.getAllLeads();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Lead> getLeadById(String id) async {
    try {
      return await _leadRepository.getLeadById(id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> createLead(Lead lead) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Associate the lead with the current user
      final leadWithUser = lead.copyWith(userId: _currentUserId);
      final newLead = await _leadRepository.createLead(leadWithUser);
      _leads.add(newLead);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLead(Lead lead) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ensure the lead remains associated with the current user
      final leadWithUser = lead.copyWith(userId: _currentUserId);
      final updatedLead = await _leadRepository.updateLead(leadWithUser);
      final index = _leads.indexWhere((l) => l.id == lead.id);
      if (index != -1) {
        _leads[index] = updatedLead;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLead(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _leadRepository.deleteLead(id);
      _leads.removeWhere((lead) => lead.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Lead> searchLeads(String query) {
    if (query.isEmpty) return _leads;

    return _leads.where((lead) {
      final queryLower = query.toLowerCase();
      return lead.name.toLowerCase().contains(queryLower) ||
          lead.email.toLowerCase().contains(queryLower) ||
          lead.company.toLowerCase().contains(queryLower) ||
          lead.source.toLowerCase().contains(queryLower);
    }).toList();
  }

  List<Lead> get todayFollowUps {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _leads.where((lead) {
      if (lead.nextFollowUp == null) return false;
      final followUpDate = DateTime(
        lead.nextFollowUp!.year,
        lead.nextFollowUp!.month,
        lead.nextFollowUp!.day,
      );
      return (followUpDate.isAtSameMomentAs(today) ||
              followUpDate.isAfter(today)) &&
          followUpDate.isBefore(tomorrow);
    }).toList();
  }

  List<Lead> filterLeadsByStatus(String status) {
    if (status.isEmpty) return _leads;

    return _leads.where((lead) => lead.status == status).toList();
  }
}
